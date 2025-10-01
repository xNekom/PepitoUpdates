import 'dart:async';
import 'dart:collection';
import '../utils/logger.dart';
import '../middleware/rate_limit_middleware.dart';
import 'auth_service.dart';
import 'threat_prediction_service.dart';

/// Tipos de eventos de seguridad
enum SecurityEventType {
  rateLimitViolation,
  authenticationFailure,
  invalidInput,
  suspiciousActivity,
  unauthorizedAccess,
  dataValidationFailure,
  securityHeaderMissing,
  httpsViolation,
  maliciousPattern,
  csrfViolation,
}

/// Evento de seguridad
class SecurityEvent {
  final SecurityEventType type;
  final String message;
  final DateTime timestamp;
  final String? userId;
  final String? clientId;
  final String? endpoint;
  final Map<String, dynamic>? metadata;
  final int severity; // 1-10, donde 10 es crítico
  
  SecurityEvent({
    required this.type,
    required this.message,
    required this.severity,
    DateTime? timestamp,
    this.userId,
    this.clientId,
    this.endpoint,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'severity': severity,
    'userId': userId,
    'clientId': clientId,
    'endpoint': endpoint,
    'metadata': metadata,
  };
}

/// Estadísticas de seguridad
class SecurityStats {
  final int totalEvents;
  final int criticalEvents;
  final int rateLimitViolations;
  final int authFailures;
  final int suspiciousActivities;
  final Map<SecurityEventType, int> eventsByType;
  final Map<String, int> eventsByEndpoint;
  final DateTime lastUpdate;
  
  SecurityStats({
    required this.totalEvents,
    required this.criticalEvents,
    required this.rateLimitViolations,
    required this.authFailures,
    required this.suspiciousActivities,
    required this.eventsByType,
    required this.eventsByEndpoint,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'totalEvents': totalEvents,
    'criticalEvents': criticalEvents,
    'rateLimitViolations': rateLimitViolations,
    'authFailures': authFailures,
    'suspiciousActivities': suspiciousActivities,
    'eventsByType': eventsByType.map((k, v) => MapEntry(k.name, v)),
    'eventsByEndpoint': eventsByEndpoint,
    'lastUpdate': lastUpdate.toIso8601String(),
  };
}

/// Servicio de monitoreo de seguridad
class SecurityMonitorService {
  static final SecurityMonitorService _instance = SecurityMonitorService._internal();
  factory SecurityMonitorService() => _instance;
  SecurityMonitorService._internal() {
    _startPeriodicCleanup();
    _startPredictiveAnalysis();
  }
  
  final Queue<SecurityEvent> _events = Queue<SecurityEvent>();
  final Map<String, int> _clientViolations = {};
  final Map<String, DateTime> _lastEventByClient = {};
  final AuthService _authService = AuthService();
  final RateLimitMiddleware _rateLimiter = RateLimitMiddleware();
  ThreatPredictionService get _predictionService => ThreatPredictionService.instance;
  
  Timer? _cleanupTimer;
  
  // Configuración
  static const int _maxEventsInMemory = 1000;
  static const Duration _eventRetentionPeriod = Duration(hours: 24);
  static const int _suspiciousActivityThreshold = 5;
  static const Duration _suspiciousActivityWindow = Duration(minutes: 10);
  
  /// Registra un evento de seguridad
  void logSecurityEvent(SecurityEvent event) {
    _events.add(event);
    
    // Mantener límite de eventos en memoria
    while (_events.length > _maxEventsInMemory) {
      _events.removeFirst();
    }
    
    // Actualizar contadores de violaciones por cliente
    if (event.clientId != null) {
      _clientViolations[event.clientId!] = 
          (_clientViolations[event.clientId!] ?? 0) + 1;
      _lastEventByClient[event.clientId!] = event.timestamp;
    }
    
    // Log según severidad
    if (event.severity >= 8) {
      Logger.error('EVENTO CRÍTICO DE SEGURIDAD: ${event.message}');
    } else if (event.severity >= 5) {
      Logger.warning('Evento de seguridad: ${event.message}');
    } else {
      Logger.info('Evento de seguridad: ${event.message}');
    }
    
    // Detectar actividad sospechosa
    _detectSuspiciousActivity(event);
    
    // Tomar acciones automáticas si es necesario
    _handleCriticalEvent(event);
  }
  
  /// Detecta actividad sospechosa
  void _detectSuspiciousActivity(SecurityEvent event) {
    if (event.clientId == null) return;
    
    final clientId = event.clientId!;
    final now = DateTime.now();
    
    // Contar eventos recientes del cliente
    final recentEvents = _events.where((e) => 
      e.clientId == clientId &&
      now.difference(e.timestamp) <= _suspiciousActivityWindow
    ).length;
    
    if (recentEvents >= _suspiciousActivityThreshold) {
      logSecurityEvent(SecurityEvent(
        type: SecurityEventType.suspiciousActivity,
        message: 'Actividad sospechosa detectada para cliente $clientId: $recentEvents eventos en ${_suspiciousActivityWindow.inMinutes} minutos',
        severity: 7,
        clientId: clientId,
        metadata: {
          'recent_events': recentEvents,
          'window_minutes': _suspiciousActivityWindow.inMinutes,
        },
      ));
      
      // Bloquear cliente temporalmente
      _rateLimiter.blockClient(clientId, const Duration(minutes: 30));
    }
  }
  
  /// Maneja eventos críticos
  void _handleCriticalEvent(SecurityEvent event) {
    if (event.severity < 8) return;
    
    switch (event.type) {
      case SecurityEventType.maliciousPattern:
      case SecurityEventType.unauthorizedAccess:
        // Bloquear cliente inmediatamente
        if (event.clientId != null) {
          _rateLimiter.blockClient(event.clientId!, const Duration(hours: 1));
        }
        break;
        
      case SecurityEventType.authenticationFailure:
        // Incrementar tiempo de bloqueo para intentos de autenticación fallidos
        if (event.clientId != null) {
          final violations = _clientViolations[event.clientId!] ?? 0;
          final blockDuration = Duration(minutes: violations * 5);
          _rateLimiter.blockClient(event.clientId!, blockDuration);
        }
        break;
        
      default:
        // Log adicional para otros eventos críticos
        Logger.error('Evento crítico requiere atención: ${event.toJson()}');
    }
  }
  
  /// Obtiene estadísticas de seguridad
  SecurityStats getSecurityStats() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    
    final recentEvents = _events.where((e) => e.timestamp.isAfter(last24h)).toList();
    
    final eventsByType = <SecurityEventType, int>{};
    final eventsByEndpoint = <String, int>{};
    
    int criticalEvents = 0;
    int rateLimitViolations = 0;
    int authFailures = 0;
    int suspiciousActivities = 0;
    
    for (final event in recentEvents) {
      // Contar por tipo
      eventsByType[event.type] = (eventsByType[event.type] ?? 0) + 1;
      
      // Contar por endpoint
      if (event.endpoint != null) {
        eventsByEndpoint[event.endpoint!] = (eventsByEndpoint[event.endpoint!] ?? 0) + 1;
      }
      
      // Contadores específicos
      if (event.severity >= 8) criticalEvents++;
      if (event.type == SecurityEventType.rateLimitViolation) rateLimitViolations++;
      if (event.type == SecurityEventType.authenticationFailure) authFailures++;
      if (event.type == SecurityEventType.suspiciousActivity) suspiciousActivities++;
    }
    
    return SecurityStats(
      totalEvents: recentEvents.length,
      criticalEvents: criticalEvents,
      rateLimitViolations: rateLimitViolations,
      authFailures: authFailures,
      suspiciousActivities: suspiciousActivities,
      eventsByType: eventsByType,
      eventsByEndpoint: eventsByEndpoint,
    );
  }
  
  /// Obtiene eventos recientes
  List<SecurityEvent> getRecentEvents({int limit = 50}) {
    final events = _events.toList();
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(limit).toList();
  }
  
  /// Obtiene eventos por tipo
  List<SecurityEvent> getEventsByType(SecurityEventType type, {int limit = 50}) {
    final events = _events.where((e) => e.type == type).toList();
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(limit).toList();
  }
  
  /// Obtiene clientes con más violaciones
  Map<String, int> getTopViolators({int limit = 10}) {
    final sortedViolations = _clientViolations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedViolations.take(limit));
  }
  
  /// Verifica si un cliente está en la lista de sospechosos
  bool isClientSuspicious(String clientId) {
    final violations = _clientViolations[clientId] ?? 0;
    return violations >= _suspiciousActivityThreshold;
  }
  
  /// Limpia un cliente de la lista de sospechosos
  void clearClientViolations(String clientId) {
    _clientViolations.remove(clientId);
    _lastEventByClient.remove(clientId);
    Logger.info('Violaciones limpiadas para cliente: $clientId');
  }
  
  /// Inicia limpieza periódica
  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _cleanupOldEvents();
      _cleanupOldViolations();
      _rateLimiter.cleanup();
    });
  }

  /// Inicia el análisis predictivo automático
  void _startPredictiveAnalysis() {
    // Ejecutar análisis cada 15 minutos
    Timer.periodic(const Duration(minutes: 15), (timer) async {
      try {
        await _predictionService.runPredictiveAnalysis();
        
        // Obtener predicciones críticas
        final criticalPredictions = _predictionService.getPredictionsByRiskLevel(RiskLevel.critical);
        
        // Registrar predicciones críticas como eventos de seguridad
        for (final prediction in criticalPredictions) {
          logSecurityEvent(SecurityEvent(
            type: SecurityEventType.maliciousPattern,
            message: 'Amenaza crítica predicha: ${prediction.type}',
            severity: 10,
            metadata: {
              'prediction_id': prediction.id,
              'threat_type': prediction.type.toString(),
              'confidence': prediction.confidence,
              'predicted_time': prediction.predictedTime.toIso8601String(),
              'recommendations': prediction.recommendations,
            },
          ));
        }
      } catch (e) {
        Logger.error('Error en análisis predictivo: $e');
      }
    });
  }
  
  /// Limpia eventos antiguos
  void _cleanupOldEvents() {
    final cutoff = DateTime.now().subtract(_eventRetentionPeriod);
    _events.removeWhere((event) => event.timestamp.isBefore(cutoff));
  }
  
  /// Limpia violaciones antiguas
  void _cleanupOldViolations() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    
    _lastEventByClient.removeWhere((clientId, lastEvent) {
      if (lastEvent.isBefore(cutoff)) {
        _clientViolations.remove(clientId);
        return true;
      }
      return false;
    });
  }
  
  /// Genera reporte de seguridad
  Map<String, dynamic> generateSecurityReport() {
    final stats = getSecurityStats();
    final topViolators = getTopViolators();
    final rateLimitStats = _rateLimiter.getStats();
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'security_stats': stats.toJson(),
      'top_violators': topViolators,
      'rate_limit_stats': rateLimitStats,
      'system_health': {
        'events_in_memory': _events.length,
        'tracked_clients': _clientViolations.length,
        'authenticated_user': _authService.currentUser?.id,
      },
    };
  }
  
  /// Exporta eventos para análisis
  List<Map<String, dynamic>> exportEvents({DateTime? since}) {
    final cutoff = since ?? DateTime.now().subtract(const Duration(days: 7));
    return _events
        .where((event) => event.timestamp.isAfter(cutoff))
        .map((event) => event.toJson())
        .toList();
  }
  
  /// Limpia todos los datos
  void reset() {
    _events.clear();
    _clientViolations.clear();
    _lastEventByClient.clear();
    _rateLimiter.resetAll();
    Logger.info('Monitor de seguridad reseteado');
  }
  
  /// Detiene el servicio
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}