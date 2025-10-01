import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/pepito_activity.dart';
import '../services/pepito_api_service.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

/// Configuración para el modo híbrido
enum PepitoDataSource {
  /// Solo polling local (modo actual)
  localPolling,
  /// Solo Cloud Functions (lee de Supabase)
  cloudFunctions,
  /// Híbrido: Cloud Functions + fallback a polling local
  hybrid
}

/// Provider para configurar el modo de operación (FIJO: Cloud Functions)
class PepitoDataSourceNotifier extends Notifier<PepitoDataSource> {
  @override
  PepitoDataSource build() {
    // Modo fijo: Solo Cloud Functions para producción
    return PepitoDataSource.cloudFunctions;
  }
}

final pepitoDataSourceProvider = NotifierProvider<PepitoDataSourceNotifier, PepitoDataSource>(() {
  return PepitoDataSourceNotifier();
});

/// Provider para el estado actual de Pépito con soporte híbrido
final hybridPepitoStatusProvider = NotifierProvider<HybridPepitoStatusNotifier, AsyncValue<PepitoStatus>>(() {
  return HybridPepitoStatusNotifier();
});

/// Notifier híbrido que puede funcionar con polling local o Cloud Functions
class HybridPepitoStatusNotifier extends Notifier<AsyncValue<PepitoStatus>> {
  Timer? _pollingTimer;
  StreamSubscription? _supabaseSubscription;
  PepitoStatus? _lastStatus;

  @override
  AsyncValue<PepitoStatus> build() {
    _initializeDataSource();
    return const AsyncValue.loading();
  }
  
  void _initializeDataSource() {
    final dataSource = ref.read(pepitoDataSourceProvider);
    
    switch (dataSource) {
      case PepitoDataSource.localPolling:
        _startLocalPolling();
        break;
      case PepitoDataSource.cloudFunctions:
        _startSupabaseListening();
        break;
      case PepitoDataSource.hybrid:
        _startHybridMode();
        break;
    }
  }
  
  /// Modo 1: Solo polling local (comportamiento actual)
  void _startLocalPolling() {
    Logger.info('🔄 Iniciando modo polling local');
    _fetchStatusFromAPI();
    
    _pollingTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _fetchStatusFromAPI();
    });
  }
  
  /// Modo 2: Solo Cloud Functions (lee de Supabase)
  void _startSupabaseListening() {
    Logger.info('☁️ Iniciando modo Cloud Functions');
    
    final supabaseService = ref.read(supabaseServiceProvider);
    
    // Obtener estado inicial
    _getLatestFromSupabase();
    
    // Escuchar cambios en tiempo real
    _supabaseSubscription = supabaseService
        .watchRecentActivities(limit: 1)
        .listen(
      (activities) {
        if (activities.isNotEmpty) {
          final latestActivity = activities.first;
          final status = _activityToStatus(latestActivity);
          
          if (_shouldUpdateStatus(status)) {
            Logger.info('📡 Nuevo estado desde Supabase: ${status.type}');
            _lastStatus = status;
            state = AsyncValue.data(status);
          }
        }
      },
      onError: (error, stackTrace) {
        Logger.error('Error escuchando Supabase: $error');
        state = AsyncValue.error(_handleError(error, stackTrace), stackTrace);
      },
    );
  }
  
  /// Modo 3: Híbrido (Cloud Functions + fallback)
  void _startHybridMode() {
    Logger.info('🔀 Iniciando modo híbrido');
    
    // Primero intentar obtener desde Supabase
    _getLatestFromSupabase().then((hasData) {
      if (hasData) {
        // Si hay datos en Supabase, usar modo Cloud Functions
        Logger.info('Datos encontrados en Supabase, usando Cloud Functions');
        _startSupabaseListening();
      } else {
        // Si no hay datos, usar polling local como fallback
        Logger.info('No hay datos en Supabase, usando polling local como fallback');
        _startLocalPolling();
        
        // Verificar cada 30 minutos si ya hay datos de Cloud Functions
        Timer.periodic(const Duration(minutes: 30), (_) {
          _checkForCloudFunctionData();
        });
      }
    });
  }
  
  /// Obtener el último estado desde Supabase
  Future<bool> _getLatestFromSupabase() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final activities = await supabaseService.getStatusHistory(limit: 1);
      
      if (activities.isNotEmpty) {
        final latestActivity = activities.first;
        final status = _activityToStatus(latestActivity);
        
        _lastStatus = status;
        state = AsyncValue.data(status);
        return true;
      }
      
      return false;
    } catch (e, stackTrace) {
      Logger.error('Error obteniendo datos de Supabase: $e');
      state = AsyncValue.error(_handleError(e, stackTrace), stackTrace);
      return false;
    }
  }
  
  /// Verificar si ya hay datos de Cloud Functions disponibles
  Future<void> _checkForCloudFunctionData() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final activities = await supabaseService.getStatusHistory(limit: 1);
      
      if (activities.isNotEmpty) {
        final latestActivity = activities.first;
        
        // Verificar si el dato es reciente (últimos 10 minutos)
        final now = DateTime.now();
        final activityAge = now.difference(latestActivity.timestamp).inSeconds;
        
        if (activityAge < 600) { // 10 minutos
          Logger.info('🔄 Detectados datos recientes de Cloud Functions, cambiando modo');
          _cleanup();
          _startSupabaseListening();
        }
      }
    } catch (e) {
      Logger.error('Error verificando datos de Cloud Functions: $e');
    }
  }
  
  /// Obtener estado desde la API (modo polling local)
  Future<void> _fetchStatusFromAPI() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final supabaseService = ref.read(supabaseServiceProvider);
      
      final newStatus = await apiService.getCurrentStatus();
      
      // Verificar si el estado ha cambiado
      if (_shouldUpdateStatus(newStatus)) {
        Logger.info('🔄 Nuevo estado desde API: ${newStatus.type} (timestamp: ${newStatus.timestamp})');
        
        // Guardar en Supabase solo si hay cambio
        if (newStatus.lastActivity != null) {
          try {
            await supabaseService.logStatusUpdate(newStatus.lastActivity!);
            Logger.info('💾 Estado guardado en Supabase: ${newStatus.type}');
          } catch (e) {
            Logger.error('Error guardando status en Supabase: $e');
          }
        }
        
        _lastStatus = newStatus;
      }
      
      state = AsyncValue.data(newStatus);
    } catch (e, stackTrace) {
      Logger.error('Error obteniendo estado desde API: $e');
      state = AsyncValue.error(_handleError(e, stackTrace), stackTrace);
    }
  }
  
  /// Convertir actividad de Supabase a PepitoStatus
  PepitoStatus _activityToStatus(PepitoActivity activity) {
    return PepitoStatus(
      event: activity.event,
      type: activity.type,
      timestamp: activity.timestamp,
      img: activity.img,
    );
  }
  
  /// Verificar si se debe actualizar el estado
  bool _shouldUpdateStatus(PepitoStatus newStatus) {
    return _lastStatus == null || 
           _lastStatus!.type != newStatus.type || 
           _lastStatus!.timestamp != newStatus.timestamp;
  }
  
  /// Limpiar recursos
  void _cleanup() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    
    _supabaseSubscription?.cancel();
    _supabaseSubscription = null;
  }
  
  /// Método para forzar actualización manual
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    final dataSource = ref.read(pepitoDataSourceProvider);
    
    switch (dataSource) {
      case PepitoDataSource.localPolling:
      case PepitoDataSource.hybrid:
        await _fetchStatusFromAPI();
        break;
      case PepitoDataSource.cloudFunctions:
        await _getLatestFromSupabase();
        break;
    }
  }
  
  /// Cambiar modo de operación (SOLO PARA DESARROLLO - En producción siempre Cloud Functions)
  void setDataSource(PepitoDataSource source) {
    // En producción, solo permitir Cloud Functions
    if (kReleaseMode && source != PepitoDataSource.cloudFunctions) {
      Logger.warning('Intento de cambiar modo en producción bloqueado. Solo Cloud Functions permitido.');
      return;
    }
    ref.read(pepitoDataSourceProvider.notifier).state = source;
  }
}

/// Provider para obtener información sobre el estado del sistema
final systemStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final dataSource = ref.watch(pepitoDataSourceProvider);
  final statusState = ref.watch(hybridPepitoStatusProvider);
  
  return {
    'dataSource': dataSource.toString().split('.').last,
    'isLoading': statusState.isLoading,
    'hasError': statusState.hasError,
    'lastUpdate': statusState.hasValue ? 
        statusState.value!.timestamp : null,
  };
});

// Función helper para manejar errores de conexión en web
Object _handleError(Object error, StackTrace stackTrace) {
  if (error is DioException && error.type == DioExceptionType.connectionError && kIsWeb) {
    return 'Error de conexión. Para desarrollo web, ejecuta con CORS deshabilitado usando run_with_cors_disabled.bat';
  }
  return error;
}

// Parámetros para providers
class FirestoreHistoryParams {
  final int limit;
  final DateTime? since;
  
  FirestoreHistoryParams({required this.limit, this.since});
}

class FirestoreStatsParams {
  final DateTime startDate;
  final DateTime endDate;
  
  FirestoreStatsParams({required this.startDate, required this.endDate});
}

// Re-exportar providers necesarios del archivo original
final apiServiceProvider = Provider<PepitoApiService>((ref) {
  final service = PepitoApiService();
  service.initialize();
  return service;
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});