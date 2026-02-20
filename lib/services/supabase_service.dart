import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pepito_activity.dart';
import '../utils/logger.dart';
import '../config/supabase_config.dart';
import 'transaction_service.dart';

class SupabaseService {
  late final SupabaseClient _client;
  
  // Getter público para acceso desde utilidades de debugging
  SupabaseClient get client => _client;
  
  SupabaseService() {
    _client = Supabase.instance.client;
  }
  
  /// Almacena una actualización de estado en Supabase de forma segura
  Future<bool> logStatusUpdate(PepitoActivity activity) async {
    return await TransactionService.executeTransaction(
      () async {
        Logger.info('Iniciando almacenamiento seguro de actividad');
        
        // Incluir todos los campos requeridos
        final data = <String, dynamic>{
          // Campos básicos requeridos
          'event': activity.event.isNotEmpty ? activity.event : 'pepito',
          'type': activity.type.toString().split('.').last,
          'timestamp': activity.timestamp.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          
          // Campo description requerido
          'description': 'Actividad de ${activity.event}: ${activity.type.toString().split('.').last}',
          
          // Campo source (si también es requerido)
          'source': 'pepito_api',
          
          // Campos opcionales
          if (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
            'image_url': activity.imageUrl,
          if (activity.id != null && activity.id!.isNotEmpty)
            'activity_id': activity.id,
          
          // Metadata como JSON
          'metadata': {
            ...activity.metadata ?? {},
            'api_timestamp': activity.timestamp.millisecondsSinceEpoch,
            'processed_at': DateTime.now().toIso8601String(),
          },
        };
        
        // Validar que los campos requeridos no sean null
        if (data['event'] == null || data['type'] == null || data['timestamp'] == null || data['description'] == null) {
          Logger.error('Campos requeridos son null, saltando inserción');
          return false;
        }
        
        Logger.info('Datos a insertar: ${data.keys.join(', ')}');
        
        // Usar inserción segura que verifica duplicados
        final success = await TransactionService.safeInsert(
          table: SupabaseConfig.activitiesTable,
          data: data,
          uniqueFields: ['timestamp', 'type'], // Evitar duplicados por timestamp y tipo
        );
        
        if (success) {
          Logger.info('Actividad almacenada exitosamente: ${activity.event} (timestamp: ${activity.timestamp})');
        } else {
          Logger.info('Actividad ya existe, preservando: ${activity.event} (timestamp: ${activity.timestamp})');
          // Retornar true porque no es un error que ya exista
          return true;
        }
        
        return success;
      },
      description: 'Almacenamiento de actividad ${activity.event}',
    );
  }
  
  /// Obtiene el historial de actualizaciones de estado desde Supabase
  Future<List<PepitoActivity>> getStatusHistory({
    int limit = 50,
    DateTime? since,
  }) async {
    try {
      Logger.info('Obteniendo historial de estado desde Supabase${since != null ? ' desde ${since.toIso8601String()}' : ''}');
      
      var query = _client
        .from(SupabaseConfig.activitiesTable)
        .select();
      
      // Filtrar por fecha si se proporciona
      if (since != null) {
        query = query.gte('timestamp', since.toIso8601String());
      }
      
      final response = await query
        .order('timestamp', ascending: false)
        .limit(limit);
      final activities = response
          .map((data) => _mapToActivity(data))
          .toList();
      
      Logger.info('Obtenidas ${activities.length} actualizaciones desde Supabase');
      return activities;
    } catch (e) {
      Logger.error('Error obteniendo historial desde Supabase: $e');
      return [];
    }
  }
  
  /// Obtiene estadísticas de actividad desde Supabase
  Future<Map<String, dynamic>> getActivityStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Logger.info('Obteniendo estadísticas de actividad desde Supabase');

      var query = _client
          .from(SupabaseConfig.activitiesTable)
          .select();

      // ✅ CORREGIDO: Usar formato ISO para las fechas (no Unix timestamps)
      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('timestamp', endDate.toIso8601String());
      }

      final response = await query;
      final data = response as List<dynamic>;

      Logger.info('Obtenidos ${data.length} registros para estadísticas');

      return _calculateStatistics(data.cast<Map<String, dynamic>>());
    } catch (e) {
      Logger.error('Error obteniendo estadísticas desde Supabase: $e');

      // ✅ FALLBACK: Devolver estadísticas básicas en caso de error
      return _getEmptyStatistics();
    }
  }
  
  /// Obtiene actividades de hoy desde Supabase
  Future<List<PepitoActivity>> getTodayActivities() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      return await getStatusHistory(
        limit: 100,
        since: startOfDay,
      );
    } catch (e) {
      Logger.error('Error obteniendo actividades de hoy desde Supabase: $e');
      return [];
    }
  }
  
  /// Elimina actividades antiguas (limpieza de datos)
  Future<bool> cleanupOldActivities({int daysToKeep = 30}) async {
    try {
      Logger.info('Limpiando actividades antiguas de Supabase');
      
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch ~/ 1000;
      
      await _client
          .from(SupabaseConfig.activitiesTable)
          .delete()
          .lt('timestamp', cutoffTimestamp);
      
      Logger.info('Actividades antiguas eliminadas exitosamente');
      return true;
    } catch (e) {
      Logger.error('Error limpiando actividades antiguas: $e');
      return false;
    }
  }

  /// Elimina TODAS las actividades de Supabase con validación
  Future<bool> clearAllActivities() async {
    return await TransactionService.executeTransaction(
      () async {
        Logger.info('Iniciando eliminación segura de todas las actividades');
        
        // Obtener conteo actual antes de eliminar
        final currentCount = await getTotalActivitiesCount();
        Logger.info('Actividades a eliminar: $currentCount');
        
        if (currentCount == 0) {
          Logger.info('No hay actividades para eliminar');
          return true;
        }
        
        // Usar eliminación segura
        final success = await TransactionService.safeDelete(
          table: SupabaseConfig.activitiesTable,
          condition: 'id IS NOT NULL',
          conditionValues: {}, // Sin condiciones específicas = eliminar todo
          expectedCount: null, // No validar conteo específico
        );
        
        if (success) {
          Logger.info('Limpieza completa: todas las actividades eliminadas');
        } else {
          Logger.error('Error durante la eliminación segura');
        }
        
        return success;
      },
      description: 'Eliminación completa de actividades',
    );
  }
  
  /// Obtiene el conteo total de actividades
  Future<int> getTotalActivitiesCount() async {
    try {
      Logger.info('Obteniendo conteo total de actividades desde Supabase');
      
      final response = await _client
          .from(SupabaseConfig.activitiesTable)
          .select('id')
          .count(CountOption.exact);
      
      return response.count;
    } catch (e) {
      Logger.error('Error obteniendo conteo total desde Supabase: $e');
      return 0;
    }
  }
  
  /// Escucha cambios en tiempo real con manejo de errores
  Stream<List<PepitoActivity>> watchRecentActivities({int limit = 10}) {
    try {
      return _client
          .from(SupabaseConfig.activitiesTable)
          .stream(primaryKey: ['id'])
          .order('timestamp', ascending: false)
          .limit(limit)
          .handleError((error) {
            Logger.error('Error en stream de Supabase: $error');
            // Retornar stream vacío en caso de error
            return <Map<String, dynamic>>[];
          })
          .map((data) => data
              .map((item) {
                try {
                  return _mapToActivity(item);
                } catch (e) {
                  Logger.error('Error mapeando actividad en stream: $e');
                  return null;
                }
              })
              .where((activity) => activity != null)
              .cast<PepitoActivity>()
              .toList());
    } catch (e) {
      Logger.error('Error configurando stream de Supabase: $e');
      // Retornar stream vacío
      return Stream.value(<PepitoActivity>[]);
    }
  }
  
  /// Convierte un documento de Supabase a PepitoActivity
  PepitoActivity _mapToActivity(Map<String, dynamic> data) {
    // ✅ CORREGIDO: Manejar timestamps ISO directamente
    DateTime timestamp;
    try {
      if (data['timestamp'] is String) {
        timestamp = DateTime.parse(data['timestamp']);
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      Logger.error('Error parseando timestamp: ${data['timestamp']} - $e');
      timestamp = DateTime.now();
    }
    
    // ✅ CORREGIDO: Manejar el tipo como string
    String activityType;
    final typeString = data['type']?.toString().toLowerCase() ?? 'unknown';
    switch (typeString) {
      case 'in':
      case 'entrada':
        activityType = 'in';
        break;
      case 'out':
      case 'salida':
        activityType = 'out';
        break;
      default:
        activityType = 'in'; // Default a 'in' si es desconocido
    }
    
    return PepitoActivity(
      id: data['id']?.toString(),
      event: data['event']?.toString() ?? 'pepito',
      type: activityType,
      timestamp: timestamp,
      imageUrl: data['image_url']?.toString(),
      metadata: data['metadata'] is Map 
          ? Map<String, dynamic>.from(data['metadata']) 
          : <String, dynamic>{},
    );
  }
  
  /// Calcula estadísticas básicas de los datos
  Map<String, dynamic> _calculateStatistics(List<Map<String, dynamic>> data) {
    try {
      final entries = data.where((item) => 
        item['type']?.toString().toLowerCase() == 'in' || 
        item['type']?.toString().toLowerCase() == 'entrada'
      ).length;
      
      final exits = data.where((item) => 
        item['type']?.toString().toLowerCase() == 'out' || 
        item['type']?.toString().toLowerCase() == 'salida'
      ).length;
      
      final total = data.length;
      
      // ✅ CORREGIDO: Convertir los datos a actividades de forma más segura
      final activities = <PepitoActivity>[];
      
      for (final item in data) {
        try {
          final activity = _mapToActivity(item);
          activities.add(activity);
        } catch (e) {
          Logger.error('Error mapeando actividad individual: $e');
          // Continuar con el siguiente elemento
        }
      }
      
      // ✅ CORREGIDO: Obtener timestamps directamente de los datos ISO
      DateTime? periodStart;
      DateTime? periodEnd;
      
      if (data.isNotEmpty) {
        try {
          // Usar los timestamps ISO directamente de la base de datos
          final timestamps = data
              .map((item) => DateTime.parse(item['timestamp'].toString()))
              .toList();
          
          timestamps.sort();
          periodStart = timestamps.first;
          periodEnd = timestamps.last;
        } catch (e) {
          Logger.error('Error procesando timestamps para estadísticas: $e');
        }
      }
      
      final stats = {
        'total_activities': total,
        'total_entries': entries,
        'total_exits': exits,
        'entry_percentage': total > 0 ? (entries / total * 100).round() : 0,
        'exit_percentage': total > 0 ? (exits / total * 100).round() : 0,
        'period_start': periodStart?.toIso8601String(),
        'period_end': periodEnd?.toIso8601String(),
        'activities': activities,
        'last_activity': activities.isNotEmpty ? activities.last : null,
        'first_activity': activities.isNotEmpty ? activities.first : null,
      };
      
      Logger.info('Estadísticas calculadas: ${stats['total_activities']} actividades, ${stats['total_entries']} entradas, ${stats['total_exits']} salidas');
      
      return stats;
      
    } catch (e) {
      Logger.error('Error calculando estadísticas: $e');
      return _getEmptyStatistics();
    }
  }
  
  /// Verifica si Supabase está disponible
  Future<bool> isAvailable() async {
    try {
      // Hacer una consulta simple para verificar conectividad
      await _client
          .from(SupabaseConfig.activitiesTable)
          .select('id')
          .limit(1);
      return true;
    } catch (e) {
      Logger.error('Supabase no está disponible: $e');
      return false;
    }
  }
  
  /// Obtiene el estado de configuración
  String get configurationStatus {
    return SupabaseConfig.configurationStatus;
  }
  
  /// Método para estadísticas vacías en caso de error
  Map<String, dynamic> _getEmptyStatistics() {
    return {
      'total_activities': 0,
      'total_entries': 0,
      'total_exits': 0,
      'entry_percentage': 0,
      'exit_percentage': 0,
      'period_start': null,
      'period_end': null,
      'activities': <PepitoActivity>[],
      'error': 'No se pudieron cargar las estadísticas',
    };
  }
}