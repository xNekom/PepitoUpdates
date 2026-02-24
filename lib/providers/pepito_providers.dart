import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/pepito_activity.dart';
import '../services/pepito_api_service.dart';

import '../services/sse_service.dart';
import '../services/supabase_service.dart';
import '../services/localization_service.dart';
import '../utils/date_utils.dart';
import '../utils/logger.dart';

// Exportar PepitoStatus para que esté disponible
export '../models/pepito_activity.dart' show PepitoStatus, ActivityType;

// Provider para el servicio de API
// Provider para el servicio de API
final apiServiceProvider = Provider<PepitoApiService>((ref) {
  final service = PepitoApiService();
  service.initialize();
  return service;
});



// Provider para el servicio de Supabase
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Provider para el historial de actividades desde Supabase
final supabaseHistoryProvider = FutureProvider.family<List<PepitoActivity>, SupabaseHistoryParams>(
  (ref, params) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getStatusHistory(
      limit: params.limit,
      since: params.since,
    );
  },
);

// Provider para estadísticas desde Supabase
final supabaseStatisticsProvider = FutureProvider.family<Map<String, dynamic>, SupabaseStatsParams>(
  (ref, params) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getActivityStatistics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  },
);

// Provider para actividades de hoy desde Supabase
final supabaseTodayActivitiesProvider = FutureProvider<List<PepitoActivity>>(
  (ref) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getTodayActivities();
  },
);

// ✅ COMENTAR TEMPORALMENTE para evitar errores
// Provider para stream de actividades en tiempo real
// final supabaseRealtimeActivitiesProvider = StreamProvider<List<PepitoActivity>>(
//   (ref) {
//     final supabaseService = ref.read(supabaseServiceProvider);
//     return supabaseService.watchRecentActivities(limit: 10);
//   },
// );

// Provider para limpiar todas las actividades de Supabase
final clearSupabaseActivitiesProvider = FutureProvider<bool>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.clearAllActivities();
});

// Provider para todas las actividades (sin paginación, para estadísticas)
final allActivitiesProvider = FutureProvider<List<PepitoActivity>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  return await supabaseService.getStatusHistory(
    limit: 10000, // Número grande para obtener todas
    since: null, // Desde el inicio
  );
});


// Provider para el servicio SSE
final sseServiceProvider = Provider<SSEService>((ref) {
  return SSEService();
});

// Provider para el stream de actividades en tiempo real
final realTimeActivitiesProvider = StreamProvider<PepitoActivity>((ref) {
  final sseService = ref.read(sseServiceProvider);
  return sseService.activityStream;
});

// Provider para el estado de conexión SSE
class SSEConnectionNotifier extends Notifier<bool> {
  @override
  bool build() {
    final sseService = ref.read(sseServiceProvider);
    return sseService.isConnected;
  }
}

final sseConnectionProvider = NotifierProvider<SSEConnectionNotifier, bool>(() {
  return SSEConnectionNotifier();
});

// Provider para el estado actual de Pépito
// Provider para el estado actual con polling automático
final pepitoStatusProvider = NotifierProvider<PepitoStatusNotifier, AsyncValue<PepitoStatus>>(() {
  return PepitoStatusNotifier();
});

// Notifier que maneja el polling automático del estado
class PepitoStatusNotifier extends Notifier<AsyncValue<PepitoStatus>> {
  Timer? _pollingTimer;
  PepitoStatus? _lastStatus;

  @override
  AsyncValue<PepitoStatus> build() {
    _startPolling();
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    return const AsyncValue.loading();
  }

  void _startPolling() {
    // Obtener estado inicial inmediatamente
    _fetchStatus();

    // Configurar polling adaptativo (reducido a 2 minutos)
    _pollingTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _fetchStatus();
    });
  }

  Future<void> _fetchStatus() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final supabaseService = ref.read(supabaseServiceProvider);

      final newStatus = await apiService.getCurrentStatus();

        // Verificar si el estado ha cambiado
      bool hasChanged = _lastStatus == null ||
          _lastStatus!.type != newStatus.type ||
          _lastStatus!.timestamp != newStatus.timestamp;

      if (hasChanged) {
        Logger.info('Nuevo estado detectado: ${newStatus.type} (timestamp: ${newStatus.timestamp})');

        // Validar y guardar en Supabase de forma segura
        if (newStatus.lastActivity != null) {
          try {
            Logger.info('Iniciando almacenamiento seguro de actividad');
            await _safeLogStatusUpdate(supabaseService, newStatus.lastActivity!);
            Logger.info('Estado guardado en Supabase: ${newStatus.type}');
          } catch (e) {
            Logger.error('Error en inserción segura en pepito_activities: $e');
            // No relanzar el error para evitar crashes
          }
        }        _lastStatus = newStatus;
      } else {
        Logger.debug('Estado sin cambios: ${newStatus.type} (timestamp: ${newStatus.timestamp})');
      }

      state = AsyncValue.data(newStatus);
    } catch (e, stackTrace) {
      Logger.error('Error obteniendo estado: $e');
      state = AsyncValue.error(_handleError(e, stackTrace), stackTrace);
    }
  }

  // Método seguro para insertar actividades
  Future<void> _safeLogStatusUpdate(SupabaseService supabaseService, PepitoActivity activity) async {
    try {
      // Validar que la actividad tenga datos válidos
      if (activity.event.isEmpty) {
        Logger.error('Actividad con evento vacío, saltando inserción');
        return;
      }

      // Verificar si la actividad ya existe para evitar duplicados
      final existingActivities = await supabaseService.getStatusHistory(
        limit: 1,
        since: activity.timestamp.subtract(const Duration(seconds: 1)),
      );

      final isDuplicate = existingActivities.any((existing) =>
        existing.timestamp.isAtSameMomentAs(activity.timestamp) &&
        existing.type == activity.type &&
        existing.event == activity.event
      );

      if (isDuplicate) {
        Logger.info('Actividad ya existe, preservando: ${activity.event} (id: ${activity.id})');
        return;
      }

      // Insertar la nueva actividad
      await supabaseService.logStatusUpdate(activity);
      Logger.info('Actividad insertada exitosamente en Supabase');

    } catch (e) {
      // Capturar y loggear el error específico sin relanzar
      Logger.error('Error en inserción segura: $e');

      // Si es un error de tipo null, intentar crear una actividad válida
      if (e.toString().contains('null: type \'Null\' is not a subtype of type \'Object\'')) {
        try {
          Logger.info('Intentando crear actividad con datos seguros...');
          await _createSafeActivity(supabaseService, activity);
        } catch (safeError) {
          Logger.error('Error en creación segura: $safeError');
        }
      }
    }
  }

  // Crear actividad con datos completamente seguros
  Future<void> _createSafeActivity(SupabaseService supabaseService, PepitoActivity activity) async {
    // Crear una nueva actividad con todos los campos validados
    final safeActivity = PepitoActivity(
      id: null, // Dejar que Supabase genere el ID
      event: activity.event.isNotEmpty ? activity.event : 'pepito',
      type: activity.type,
      timestamp: activity.timestamp,
      imageUrl: activity.imageUrl, // Puede ser null
      metadata: activity.metadata ?? {}, // Asegurar que no sea null
    );

    // Intentar insertar la actividad segura
    await supabaseService.logStatusUpdate(safeActivity);
    Logger.info('Actividad segura creada exitosamente');
  }

  // Método para forzar actualización manual
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _fetchStatus();
  }
}

// Función helper para manejar errores de conexión en web
Object _handleError(Object error, StackTrace stackTrace) {
  if (error is DioException && error.type == DioExceptionType.connectionError && kIsWeb) {
    return 'Error de conexión. Para desarrollo web, ejecuta con CORS deshabilitado usando run_with_cors_disabled.bat';
  }
  return error;
}

// Provider para las actividades de hoy (solo API local)
final todayActivitiesLocalProvider = FutureProvider<List<PepitoActivity>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getTodayActivities();
});



// Provider para las actividades de hoy (solo API local, sin almacenamiento automático)
final todayActivitiesProvider = FutureProvider<List<PepitoActivity>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getTodayActivities();
});

// Provider para todas las actividades con paginación (solo API local)
final activitiesLocalProvider = FutureProvider.family<List<PepitoActivity>, ActivitiesParams>(
  (ref, params) async {
    final apiService = ref.read(apiServiceProvider);
    return await apiService.getActivities(
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
      offset: params.offset,
    );
  },
);



// Provider para todas las actividades con paginación (usando Supabase para historial)
final activitiesProvider = FutureProvider.family<List<PepitoActivity>, ActivitiesParams>(
  (ref, params) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    
    // Obtener todas las actividades desde Supabase
    final allActivities = await supabaseService.getStatusHistory(
      limit: 1000, // Obtener un número grande para filtrar después
      since: params.startDate,
    );
    
    // Filtrar por rango de fechas si se especifica endDate
    List<PepitoActivity> filteredActivities = allActivities;
    if (params.endDate != null) {
      filteredActivities = allActivities
          .where((activity) => activity.timestamp.isBefore(params.endDate!) || 
                               activity.timestamp.isAtSameMomentAs(params.endDate!))
          .toList();
    }
    
    // Aplicar paginación
    final startIndex = params.offset;
    final endIndex = startIndex + params.limit;
    
    if (startIndex >= filteredActivities.length) {
      return [];
    }
    
    return filteredActivities.sublist(
      startIndex,
      endIndex > filteredActivities.length ? filteredActivities.length : endIndex,
    );
  },
);

// Provider para estadísticas (solo API local)
final statisticsLocalProvider = FutureProvider.family<Map<String, dynamic>, StatisticsParams>(
  (ref, params) async {
    final apiService = ref.read(apiServiceProvider);
    return await apiService.getStatistics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  },
);

// Provider para estadísticas (alias del provider de Supabase para compatibilidad)
final statisticsProvider = FutureProvider.family<Map<String, dynamic>, StatisticsParams>(
  (ref, params) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    return await supabaseService.getActivityStatistics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  },
);

// Provider para el estado de conexión
class ConnectionStatusNotifier extends Notifier<bool> {
  @override
  bool build() => true;
}

final connectionStatusProvider = NotifierProvider<ConnectionStatusNotifier, bool>(() {
  return ConnectionStatusNotifier();
});

// Provider para el estado de carga
class LoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

final loadingProvider = NotifierProvider<LoadingNotifier, bool>(() {
  return LoadingNotifier();
});

// Provider para errores
class ErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;
}

final errorProvider = NotifierProvider<ErrorNotifier, String?>(() {
  return ErrorNotifier();
});

// Provider para la configuración de notificaciones
final notificationSettingsProvider = NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  () => NotificationSettingsNotifier(),
);

// Provider para el filtro de actividades
final activityFilterProvider = NotifierProvider<ActivityFilterNotifier, ActivityFilter>(
  () => ActivityFilterNotifier(),
);



// Clases auxiliares
class ActivitiesParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;
  final int offset;

  const ActivitiesParams({
    this.startDate,
    this.endDate,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivitiesParams &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    return startDate.hashCode ^
        endDate.hashCode ^
        limit.hashCode ^
        offset.hashCode;
  }
}

class StatisticsParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const StatisticsParams({
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatisticsParams &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

class SupabaseHistoryParams {
  final int limit;
  final DateTime? since;

  const SupabaseHistoryParams({
    this.limit = 50,
    this.since,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupabaseHistoryParams &&
        other.limit == limit &&
        other.since == since;
  }

  @override
  int get hashCode => limit.hashCode ^ since.hashCode;
}

class SupabaseStatsParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const SupabaseStatsParams({
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupabaseStatsParams &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

class NotificationSettings {
  final bool enabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showOnLockScreen;
  final bool pushEnabled;
  final bool entryNotifications;
  final bool exitNotifications;
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  const NotificationSettings({
    this.enabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showOnLockScreen = true,
    this.pushEnabled = true,
    this.entryNotifications = true,
    this.exitNotifications = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showOnLockScreen,
    bool? pushEnabled,
    bool? entryNotifications,
    bool? exitNotifications,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showOnLockScreen: showOnLockScreen ?? this.showOnLockScreen,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      entryNotifications: entryNotifications ?? this.entryNotifications,
      exitNotifications: exitNotifications ?? this.exitNotifications,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    return const NotificationSettings();
  }

  void updateEnabled(bool enabled) {
    state = state.copyWith(enabled: enabled);
  }

  void updateSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
  }

  void updateVibrationEnabled(bool enabled) {
    state = state.copyWith(vibrationEnabled: enabled);
  }

  void updateShowOnLockScreen(bool enabled) {
    state = state.copyWith(showOnLockScreen: enabled);
  }

  void updateQuietHoursEnabled(bool enabled) {
    state = state.copyWith(quietHoursEnabled: enabled);
  }

  void updateQuietHoursStart(TimeOfDay time) {
    state = state.copyWith(quietHoursStart: time);
  }

  void updateQuietHoursEnd(TimeOfDay time) {
    state = state.copyWith(quietHoursEnd: time);
  }
  
  void updateExitNotifications(bool enabled) {
    state = state.copyWith(exitNotifications: enabled);
  }
  
  void updatePushEnabled(bool enabled) {
    state = state.copyWith(pushEnabled: enabled);
  }
  
  void updateEntryNotifications(bool enabled) {
    state = state.copyWith(entryNotifications: enabled);
  }
}

class ActivityFilter {
  final String? type; // 'entrada', 'salida', null para todos
  final ActivityType? activityType;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateRange? dateRange;
  final String searchQuery;

  const ActivityFilter({
    this.type,
    this.activityType,
    this.startDate,
    this.endDate,
    this.dateRange,
    this.searchQuery = '',
  });

  ActivityFilter copyWith({
    String? type,
    ActivityType? activityType,
    DateTime? startDate,
    DateTime? endDate,
    DateRange? dateRange,
    String? searchQuery,
  }) {
    return ActivityFilter(
      type: type ?? this.type,
      activityType: activityType ?? this.activityType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dateRange: dateRange ?? this.dateRange,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters {
    return type != null ||
        activityType != null ||
        startDate != null ||
        endDate != null ||
        dateRange != null ||
        searchQuery.isNotEmpty;
  }
}

class ActivityFilterNotifier extends Notifier<ActivityFilter> {
  @override
  ActivityFilter build() {
    return const ActivityFilter();
  }

  void clearFilters() {
    state = const ActivityFilter();
  }

  void setActivityType(ActivityType? activityType) {
    state = state.copyWith(activityType: activityType);
  }

  void setDateRange(DateRange? dateRange) {
    state = state.copyWith(dateRange: dateRange);
  }

  void updateFilter({
    ActivityType? activityType,
    DateRange? dateRange,
    String? searchQuery,
  }) {
    state = state.copyWith(
      activityType: activityType,
      dateRange: dateRange,
      searchQuery: searchQuery,
    );
  }
}

enum AppThemeMode {
  light,
  dark,
  system,
}

// Provider para el tema de la aplicación
final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  () => ThemeNotifier(),
);

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    return AppThemeMode.system;
  }

  void setThemeMode(AppThemeMode mode) {
    state = mode;
  }
}

// Provider para refrescar datos
final refreshProvider = Provider<RefreshController>((ref) {
  return RefreshController(ref);
});

class RefreshController {
  final Ref ref;
  bool _isRefreshing = false; // Agregar flag de control

  RefreshController(this.ref);

  Future<void> refreshStatus() async {
    if (_isRefreshing) return; // Evitar refreshes simultáneos

    _isRefreshing = true;
    try {
      await ref.read(pepitoStatusProvider.notifier).refresh();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> refreshTodayActivities() async {
    if (_isRefreshing) return;
    ref.invalidate(todayActivitiesProvider);
  }

  Future<void> refreshActivities() async {
    if (_isRefreshing) return;
    ref.invalidate(activitiesProvider);
  }

  Future<void> refreshStatistics() async {
    if (_isRefreshing) return;
    ref.invalidate(statisticsProvider);
  }

  Future<void> refreshAll() async {
    if (_isRefreshing) return; // Evitar refreshes simultáneos

    _isRefreshing = true;
    try {
      // Usar un pequeño delay entre refreshes para evitar sobrecarga
      await ref.read(pepitoStatusProvider.notifier).refresh();
      await Future.delayed(const Duration(milliseconds: 100));

      ref.invalidate(todayActivitiesProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      ref.invalidate(activitiesProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      ref.invalidate(statisticsProvider);
    } finally {
      _isRefreshing = false;
    }
  }
}

// Helper para validar datos antes de insertar en Supabase
Map<String, dynamic> validateActivityData(PepitoActivity activity) {
  return {
    'event': activity.event.isNotEmpty ? activity.event : 'pepito',
    'type': activity.type.toString().split('.').last, // Convertir enum a string
    'timestamp': activity.timestamp.toIso8601String(),
    'image_url': activity.imageUrl, // Puede ser null
    'metadata': activity.metadata ?? {}, // Asegurar que no sea null
    'created_at': DateTime.now().toIso8601String(),
  };
}

// Provider para el servicio de localización
final localizationServiceProvider = Provider<LocalizationService>((ref) {
  return LocalizationService();
});

// Provider para el idioma actual
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(),
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadStoredLocale();
    return const Locale('es');
  }

  Future<void> _loadStoredLocale() async {
    final storedLocale = await LocalizationService.getStoredLocale();
    state = storedLocale;
  }

  Future<void> setLocale(Locale locale) async {
    await LocalizationService.setLocale(locale);
    state = locale;
  }
}