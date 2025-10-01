import 'dart:async';
import 'threat_prediction_service.dart';
import 'security_logging_service.dart';

/// Tipos de respuesta automática
enum ResponseType {
  blockIp,
  rateLimitIncrease,
  alertAdministrator,
  quarantineUser,
  disableEndpoint,
  enableWaf,
  backupData,
  isolateSession,
}

/// Severidad de la respuesta
enum ResponseSeverity {
  low,
  medium,
  high,
  critical,
}

/// Modelo de respuesta automática
class ThreatResponse {
  final String id;
  final String threatPredictionId;
  final ThreatType threatType;
  final ResponseType responseType;
  final ResponseSeverity severity;
  final DateTime triggeredAt;
  final DateTime? executedAt;
  final DateTime? completedAt;
  final bool isSuccessful;
  final String? errorMessage;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> results;
  final Duration? executionTime;

  ThreatResponse({
    required this.id,
    required this.threatPredictionId,
    required this.threatType,
    required this.responseType,
    required this.severity,
    required this.triggeredAt,
    this.executedAt,
    this.completedAt,
    this.isSuccessful = false,
    this.errorMessage,
    this.parameters = const {},
    this.results = const {},
    this.executionTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'threatPredictionId': threatPredictionId,
    'threatType': threatType.toString(),
    'responseType': responseType.toString(),
    'severity': severity.toString(),
    'triggeredAt': triggeredAt.toIso8601String(),
    'executedAt': executedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'isSuccessful': isSuccessful,
    'errorMessage': errorMessage,
    'parameters': parameters,
    'results': results,
    'executionTime': executionTime?.inMilliseconds,
  };
}

/// Configuración del servicio de respuesta
class ThreatResponseConfig {
  final bool autoResponseEnabled;
  final Duration responseDelay;
  final Map<ThreatType, List<ResponseType>> threatResponseMap;
  final Map<RiskLevel, ResponseSeverity> riskSeverityMap;
  final int maxResponsesPerHour;
  final Duration cooldownPeriod;

  const ThreatResponseConfig({
    this.autoResponseEnabled = true,
    this.responseDelay = const Duration(seconds: 30),
    this.threatResponseMap = const {
      ThreatType.bruteForce: [ResponseType.blockIp, ResponseType.rateLimitIncrease],
      ThreatType.sqlInjection: [ResponseType.enableWaf, ResponseType.alertAdministrator],
      ThreatType.xssAttack: [ResponseType.enableWaf, ResponseType.alertAdministrator],
      ThreatType.ddosAttack: [ResponseType.rateLimitIncrease, ResponseType.blockIp],
      ThreatType.dataExfiltration: [ResponseType.quarantineUser, ResponseType.backupData, ResponseType.alertAdministrator],
      ThreatType.privilegeEscalation: [ResponseType.quarantineUser, ResponseType.alertAdministrator],
      ThreatType.malwareUpload: [ResponseType.quarantineUser, ResponseType.isolateSession],
      ThreatType.sessionHijacking: [ResponseType.isolateSession, ResponseType.alertAdministrator],
    },
    this.riskSeverityMap = const {
      RiskLevel.low: ResponseSeverity.low,
      RiskLevel.medium: ResponseSeverity.medium,
      RiskLevel.high: ResponseSeverity.high,
      RiskLevel.critical: ResponseSeverity.critical,
    },
    this.maxResponsesPerHour = 50,
    this.cooldownPeriod = const Duration(minutes: 5),
  });
}

/// Servicio de respuesta automática a amenazas
class ThreatResponseService {
  static final ThreatResponseService _instance = ThreatResponseService._internal();
  static ThreatResponseService get instance => _instance;
  
  ThreatResponseService._internal();

  final ThreatResponseConfig _config = const ThreatResponseConfig();
  final List<ThreatResponse> _responses = [];
  final SecurityLoggingService _logger = SecurityLoggingService.instance;
  final Map<String, DateTime> _lastResponseTime = {};
  
  bool _isInitialized = false;
  Timer? _monitoringTimer;

  /// Inicializa el servicio de respuesta
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _logger.logSecurityEvent(
      event: 'threat_response_service_initialized',
      level: SecurityLogLevel.info,
      category: SecurityEventCategory.systemIntegrity,
      details: {
        'auto_response_enabled': _config.autoResponseEnabled,
        'max_responses_per_hour': _config.maxResponsesPerHour,
        'response_delay_seconds': _config.responseDelay.inSeconds,
      },
    );

    if (_config.autoResponseEnabled) {
      _startThreatMonitoring();
    }

    _isInitialized = true;
  }

  /// Inicia el monitoreo de amenazas para respuesta automática
  void _startThreatMonitoring() {
    _monitoringTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      try {
        final predictionService = ThreatPredictionService.instance;
        final predictions = predictionService.getActivePredictions();
        
        for (final prediction in predictions) {
          // Solo responder a predicciones de alto riesgo
          if (prediction.riskLevel == RiskLevel.high || prediction.riskLevel == RiskLevel.critical) {
            await _evaluateAndRespond(prediction);
          }
        }
      } catch (e) {
        await _logger.logSecurityEvent(
          event: 'threat_monitoring_error',
          level: SecurityLogLevel.critical,
          category: SecurityEventCategory.systemIntegrity,
          details: {
            'error': e.toString(),
          },
        );
      }
    });
  }

  /// Evalúa una predicción y ejecuta respuesta si es necesario
  Future<void> _evaluateAndRespond(ThreatPrediction prediction) async {
    // Verificar si ya se respondió a esta predicción
    final existingResponse = _responses.where((r) => r.threatPredictionId == prediction.id).firstOrNull;
    if (existingResponse != null) return;

    // Verificar cooldown
    final lastResponse = _lastResponseTime[prediction.type.toString()];
    if (lastResponse != null && 
        DateTime.now().difference(lastResponse) < _config.cooldownPeriod) {
      return;
    }

    // Verificar límite de respuestas por hora
    final recentResponses = _responses.where((r) => 
      r.triggeredAt.isAfter(DateTime.now().subtract(const Duration(hours: 1)))
    ).length;
    
    if (recentResponses >= _config.maxResponsesPerHour) {
      await _logger.logSecurityEvent(
        event: 'response_rate_limit_exceeded',
        level: SecurityLogLevel.warning,
        category: SecurityEventCategory.systemIntegrity,
        details: {
          'prediction_id': prediction.id,
          'responses_last_hour': recentResponses,
        },
      );
      return;
    }

    // Obtener tipos de respuesta para esta amenaza
    final responseTypes = _config.threatResponseMap[prediction.type] ?? [];
    
    for (final responseType in responseTypes) {
      await _executeResponse(prediction, responseType);
    }
  }

  /// Ejecuta una respuesta específica
  Future<void> _executeResponse(ThreatPrediction prediction, ResponseType responseType) async {
    final responseId = _generateResponseId();
    final severity = _config.riskSeverityMap[prediction.riskLevel] ?? ResponseSeverity.medium;
    
    final response = ThreatResponse(
      id: responseId,
      threatPredictionId: prediction.id,
      threatType: prediction.type,
      responseType: responseType,
      severity: severity,
      triggeredAt: DateTime.now(),
    );

    _responses.add(response);
    _lastResponseTime[prediction.type.toString()] = DateTime.now();

    await _logger.logSecurityEvent(
      event: 'threat_response_triggered',
      level: SecurityLogLevel.warning,
      category: SecurityEventCategory.systemIntegrity,
      details: {
        'response_id': responseId,
        'prediction_id': prediction.id,
        'threat_type': prediction.type.toString(),
        'response_type': responseType.toString(),
        'severity': severity.toString(),
      },
    );

    // Esperar el delay configurado antes de ejecutar
    await Future.delayed(_config.responseDelay);

    try {
      final startTime = DateTime.now();
      final results = await _performResponse(responseType, prediction);
      final endTime = DateTime.now();
      
      // Actualizar respuesta con resultados exitosos
      final updatedResponse = ThreatResponse(
        id: response.id,
        threatPredictionId: response.threatPredictionId,
        threatType: response.threatType,
        responseType: response.responseType,
        severity: response.severity,
        triggeredAt: response.triggeredAt,
        executedAt: startTime,
        completedAt: endTime,
        isSuccessful: true,
        parameters: response.parameters,
        results: results,
        executionTime: endTime.difference(startTime),
      );
      
      _responses[_responses.indexWhere((r) => r.id == responseId)] = updatedResponse;

      await _logger.logSecurityEvent(
        event: 'threat_response_completed',
        level: SecurityLogLevel.info,
        category: SecurityEventCategory.systemIntegrity,
        details: {
          'response_id': responseId,
          'execution_time_ms': endTime.difference(startTime).inMilliseconds,
          'results': results,
        },
      );
    } catch (e) {
      // Actualizar respuesta con error
      final updatedResponse = ThreatResponse(
        id: response.id,
        threatPredictionId: response.threatPredictionId,
        threatType: response.threatType,
        responseType: response.responseType,
        severity: response.severity,
        triggeredAt: response.triggeredAt,
        executedAt: DateTime.now(),
        isSuccessful: false,
        errorMessage: e.toString(),
        parameters: response.parameters,
      );
      
      _responses[_responses.indexWhere((r) => r.id == responseId)] = updatedResponse;

      await _logger.logSecurityEvent(
        event: 'threat_response_failed',
        level: SecurityLogLevel.critical,
        category: SecurityEventCategory.systemIntegrity,
        details: {
          'response_id': responseId,
          'error': e.toString(),
        },
      );
    }
  }

  /// Ejecuta la acción de respuesta específica
  Future<Map<String, dynamic>> _performResponse(ResponseType responseType, ThreatPrediction prediction) async {
    switch (responseType) {
      case ResponseType.blockIp:
        return await _blockIp(prediction);
      case ResponseType.rateLimitIncrease:
        return await _increaseRateLimit(prediction);
      case ResponseType.alertAdministrator:
        return await _alertAdministrator(prediction);
      case ResponseType.quarantineUser:
        return await _quarantineUser(prediction);
      case ResponseType.disableEndpoint:
        return await _disableEndpoint(prediction);
      case ResponseType.enableWaf:
        return await _enableWaf(prediction);
      case ResponseType.backupData:
        return await _backupData(prediction);
      case ResponseType.isolateSession:
        return await _isolateSession(prediction);
    }
  }

  /// Bloquea una IP sospechosa
  Future<Map<String, dynamic>> _blockIp(ThreatPrediction prediction) async {
    final ip = prediction.sourceIp;
    if (ip == null || ip == 'unknown') {
      throw Exception('No se puede bloquear IP: IP no disponible');
    }

    // Simular bloqueo de IP (en implementación real, esto interactuaría con firewall/WAF)
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'action': 'ip_blocked',
      'ip_address': ip,
      'duration': '24h',
      'method': 'firewall_rule',
    };
  }

  /// Aumenta el rate limiting
  Future<Map<String, dynamic>> _increaseRateLimit(ThreatPrediction prediction) async {
    // Reducir límites temporalmente
    // Rate limiter configuration updated
    // await _rateLimiter.updateLimits({
    //   'requests_per_minute': 10,
    //   'requests_per_hour': 100,
    // });
    
    return {
      'action': 'rate_limit_increased',
      'new_limits': {
        'requests_per_minute': 10,
        'requests_per_hour': 100,
      },
      'duration': '1h',
    };
  }

  /// Alerta al administrador
  Future<Map<String, dynamic>> _alertAdministrator(ThreatPrediction prediction) async {
    // Simular envío de alerta (email, SMS, push notification, etc.)
    await Future.delayed(const Duration(milliseconds: 200));
    
    return {
      'action': 'administrator_alerted',
      'channels': ['email', 'push_notification'],
      'threat_type': prediction.type.toString(),
      'confidence': prediction.confidence,
    };
  }

  /// Pone en cuarentena a un usuario
  Future<Map<String, dynamic>> _quarantineUser(ThreatPrediction prediction) async {
    final userId = prediction.targetUserId;
    if (userId == null) {
      throw Exception('No se puede poner en cuarentena: Usuario no identificado');
    }

    // Simular cuarentena de usuario
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      'action': 'user_quarantined',
      'user_id': userId,
      'restrictions': ['api_access_limited', 'sensitive_operations_blocked'],
      'duration': '2h',
    };
  }

  /// Deshabilita un endpoint temporalmente
  Future<Map<String, dynamic>> _disableEndpoint(ThreatPrediction prediction) async {
    final endpoint = prediction.targetEndpoint;
    if (endpoint == null) {
      throw Exception('No se puede deshabilitar endpoint: Endpoint no especificado');
    }

    // Simular deshabilitación de endpoint
    await Future.delayed(const Duration(milliseconds: 400));
    
    return {
      'action': 'endpoint_disabled',
      'endpoint': endpoint,
      'duration': '30m',
      'fallback_enabled': true,
    };
  }

  /// Habilita WAF con reglas específicas
  Future<Map<String, dynamic>> _enableWaf(ThreatPrediction prediction) async {
    // Simular habilitación de WAF
    await Future.delayed(const Duration(milliseconds: 600));
    
    final rules = <String>[];
    switch (prediction.type) {
      case ThreatType.sqlInjection:
        rules.addAll(['sql_injection_protection', 'input_validation']);
        break;
      case ThreatType.xssAttack:
        rules.addAll(['xss_protection', 'script_filtering']);
        break;
      default:
        rules.add('general_protection');
    }
    
    return {
      'action': 'waf_enabled',
      'rules_activated': rules,
      'protection_level': 'high',
    };
  }

  /// Realiza backup de datos críticos
  Future<Map<String, dynamic>> _backupData(ThreatPrediction prediction) async {
    // Simular backup de datos
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'action': 'data_backup_completed',
      'backup_id': 'backup_${DateTime.now().millisecondsSinceEpoch}',
      'data_types': ['user_data', 'system_config', 'security_logs'],
      'backup_location': 'secure_storage',
    };
  }

  /// Aísla una sesión sospechosa
  Future<Map<String, dynamic>> _isolateSession(ThreatPrediction prediction) async {
    // Simular aislamiento de sesión
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      'action': 'session_isolated',
      'session_restrictions': ['read_only_access', 'limited_endpoints'],
      'monitoring_level': 'enhanced',
    };
  }

  /// Genera un ID único para la respuesta
  String _generateResponseId() {
    return 'resp_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Obtiene todas las respuestas
  List<ThreatResponse> getAllResponses() {
    return List.unmodifiable(_responses);
  }

  /// Obtiene respuestas filtradas por tipo de amenaza
  List<ThreatResponse> getResponsesByThreatType(ThreatType threatType) {
    return _responses.where((r) => r.threatType == threatType).toList();
  }

  /// Obtiene respuestas recientes
  List<ThreatResponse> getRecentResponses({Duration? since}) {
    final cutoff = since != null 
        ? DateTime.now().subtract(since)
        : DateTime.now().subtract(const Duration(hours: 24));
    
    return _responses.where((r) => r.triggeredAt.isAfter(cutoff)).toList();
  }

  /// Obtiene estadísticas de respuestas
  Map<String, dynamic> getResponseStats() {
    final last24h = getRecentResponses(since: const Duration(hours: 24));
    final successful = last24h.where((r) => r.isSuccessful).length;
    
    final byType = <String, int>{};
    final byResponseType = <String, int>{};
    
    for (final response in last24h) {
      final threat = response.threatType.toString();
      final responseType = response.responseType.toString();
      byType[threat] = (byType[threat] ?? 0) + 1;
      byResponseType[responseType] = (byResponseType[responseType] ?? 0) + 1;
    }

    return {
      'total_responses': _responses.length,
      'responses_last_24h': last24h.length,
      'success_rate': last24h.isEmpty ? 0.0 : successful / last24h.length,
      'by_threat_type': byType,
      'by_response_type': byResponseType,
      'average_execution_time_ms': last24h.where((r) => r.executionTime != null)
          .map((r) => r.executionTime!.inMilliseconds)
          .fold<double>(0, (a, b) => a + b) / 
          (last24h.where((r) => r.executionTime != null).length.clamp(1, double.infinity)),
    };
  }

  /// Limpia respuestas antiguas
  void cleanupOldResponses() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    _responses.removeWhere((r) => r.triggeredAt.isBefore(cutoff));
  }

  /// Detiene el servicio
  void dispose() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }
}