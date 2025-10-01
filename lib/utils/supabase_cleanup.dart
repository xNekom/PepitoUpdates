import '../services/supabase_service.dart';
import '../utils/logger.dart';

/// Utilidades para limpiar y gestionar datos de Supabase
class SupabaseCleanup {
  static final SupabaseService _supabaseService = SupabaseService();

  /// Elimina todas las actividades de Supabase excepto la más reciente
  static Future<bool> clearAllActivities() async {
    try {
      Logger.info('Iniciando limpieza de Supabase...');
      
      await _supabaseService.clearAllActivities();
      
      Logger.info('Limpieza de Supabase completada exitosamente');
      return true;
    } catch (e) {
      Logger.error('Error durante la limpieza de Supabase: $e');
      return false;
    }
  }

  /// Muestra estadísticas actuales de Supabase
  static Future<void> showCurrentStats() async {
    try {
      Logger.info('📊 Obteniendo estadísticas de Supabase...');
      
      final totalCount = await _supabaseService.getTotalActivitiesCount();
      final recentActivities = await _supabaseService.getStatusHistory(limit: 5);
      
      Logger.info('📈 Total de actividades en Supabase: $totalCount');
      Logger.info('📋 Últimas 5 actividades:');
      
      for (int i = 0; i < recentActivities.length; i++) {
        final activity = recentActivities[i];
        final dateTime = activity.timestamp;
        Logger.info('  ${i + 1}. ${activity.type} - ${dateTime.toIso8601String()}');
      }
    } catch (e) {
      Logger.error('Error obteniendo estadísticas de Supabase: $e');
    }
  }

  /// Inspecciona datos crudos de Supabase para debugging
  static Future<void> inspectRawData() async {
    try {
      Logger.info('Inspeccionando datos crudos de Supabase...');
      
      // Obtener todas las actividades
      final allActivities = await _supabaseService.getStatusHistory(limit: 100);
      
      Logger.info('📊 Total de actividades encontradas: ${allActivities.length}');
      
      if (allActivities.isEmpty) {
        Logger.info('📭 No hay actividades en Supabase');
        return;
      }
      
      // Agrupar por tipo
      final Map<String, int> typeCount = {};
      final Map<String, List<DateTime>> typeTimestamps = {};
      
      for (final activity in allActivities) {
        typeCount[activity.type] = (typeCount[activity.type] ?? 0) + 1;
        typeTimestamps[activity.type] ??= [];
        final dateTime = activity.timestamp;
        typeTimestamps[activity.type]!.add(dateTime);
      }
      
      Logger.info('📈 Distribución por tipo:');
      typeCount.forEach((type, count) {
        Logger.info('  $type: $count actividades');
      });
      
      // Mostrar actividades más recientes
      Logger.info('🕒 Últimas 10 actividades:');
      final recentActivities = allActivities.take(10);
      for (int i = 0; i < recentActivities.length; i++) {
        final activity = recentActivities.elementAt(i);
        final dateTime = activity.timestamp;
        Logger.info('  ${i + 1}. [${dateTime.toIso8601String()}] ${activity.type}');
      }
      
      // Detectar posibles duplicados
      Logger.info('Analizando duplicados...');
      final duplicates = <String, List<DateTime>>{};
      
      typeTimestamps.forEach((type, timestamps) {
        if (timestamps.length > 1) {
          // Ordenar timestamps
          timestamps.sort();
          
          // Buscar timestamps muy cercanos (menos de 1 minuto de diferencia)
          for (int i = 0; i < timestamps.length - 1; i++) {
            final diff = timestamps[i + 1].difference(timestamps[i]).inMinutes;
            if (diff < 1) {
              duplicates[type] ??= [];
              duplicates[type]!.addAll([timestamps[i], timestamps[i + 1]]);
            }
          }
        }
      });
      
      if (duplicates.isNotEmpty) {
        Logger.warning('Posibles duplicados detectados:');
        duplicates.forEach((type, timestamps) {
          Logger.warning('  $type: ${timestamps.length} timestamps muy cercanos');
        });
      } else {
        Logger.info('No se detectaron duplicados obvios');
      }
      
    } catch (e) {
      Logger.error('Error inspeccionando datos de Supabase: $e');
    }
  }

  /// Verifica la conectividad con Supabase
  static Future<bool> checkConnection() async {
    try {
      final isAvailable = await _supabaseService.isAvailable();
      if (isAvailable) {
        Logger.info('Conexión con Supabase exitosa');
      } else {
        Logger.warning('Supabase no está disponible');
      }
      return isAvailable;
    } catch (e) {
      Logger.error('Error verificando conexión con Supabase: $e');
      return false;
    }
  }
}