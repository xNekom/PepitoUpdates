import 'dart:math' as math;
import 'security_monitor_service.dart';
import 'behavior_analysis_service.dart';
import 'security_logging_service.dart';

/// Tipos de amenazas que se pueden predecir
enum ThreatType {
  bruteForce,
  sqlInjection,
  xssAttack,
  ddosAttack,
  dataExfiltration,
  privilegeEscalation,
  malwareUpload,
  sessionHijacking,
}

/// Nivel de riesgo de la amenaza predicha
enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

/// Modelo de predicción de amenaza
class ThreatPrediction {
  final String id;
  final ThreatType type;
  final RiskLevel riskLevel;
  final double confidence;
  final DateTime predictedTime;
  final String? targetEndpoint;
  final String? targetUserId;
  final String? sourceIp;
  final Map<String, dynamic> indicators;
  final List<String> recommendations;
  final DateTime createdAt;

  ThreatPrediction({
    required this.id,
    required this.type,
    required this.riskLevel,
    required this.confidence,
    required this.predictedTime,
    this.targetEndpoint,
    this.targetUserId,
    this.sourceIp,
    required this.indicators,
    required this.recommendations,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'riskLevel': riskLevel.toString(),
    'confidence': confidence,
    'predictedTime': predictedTime.toIso8601String(),
    'targetEndpoint': targetEndpoint,
    'targetUserId': targetUserId,
    'sourceIp': sourceIp,
    'indicators': indicators,
    'recommendations': recommendations,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Configuración del servicio de predicción
class ThreatPredictionConfig {
  final Duration analysisWindow;
  final double minimumConfidence;
  final int maxPredictionsPerHour;
  final Duration predictionHorizon;
  final Map<ThreatType, double> threatWeights;

  const ThreatPredictionConfig({
    this.analysisWindow = const Duration(hours: 24),
    this.minimumConfidence = 0.7,
    this.maxPredictionsPerHour = 10,
    this.predictionHorizon = const Duration(hours: 2),
    this.threatWeights = const {
      ThreatType.bruteForce: 1.0,
      ThreatType.sqlInjection: 1.2,
      ThreatType.xssAttack: 1.1,
      ThreatType.ddosAttack: 1.3,
      ThreatType.dataExfiltration: 1.5,
      ThreatType.privilegeEscalation: 1.4,
      ThreatType.malwareUpload: 1.6,
      ThreatType.sessionHijacking: 1.2,
    },
  });
}

/// Servicio de predicción de amenazas usando análisis de patrones
class ThreatPredictionService {
  static final ThreatPredictionService _instance = ThreatPredictionService._internal();
  static ThreatPredictionService get instance => _instance;
  
  ThreatPredictionService._internal();

  final ThreatPredictionConfig _config = const ThreatPredictionConfig();
  final List<ThreatPrediction> _predictions = [];
  SecurityMonitorService get _securityMonitor => SecurityMonitorService();
  final BehaviorAnalysisService _behaviorAnalysis = BehaviorAnalysisService.instance;
  final SecurityLoggingService _logger = SecurityLoggingService.instance;
  final math.Random _random = math.Random();

  bool _isInitialized = false;

  /// Inicializa el servicio de predicción
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _logger.logSecurityEvent(
      event: 'threat_prediction_service_initialized',
      level: SecurityLogLevel.info,
      category: SecurityEventCategory.systemIntegrity,
      details: {
        'config': {
          'analysis_window_hours': _config.analysisWindow.inHours,
          'minimum_confidence': _config.minimumConfidence,
          'max_predictions_per_hour': _config.maxPredictionsPerHour,
        },
      },
    );

    _isInitialized = true;
  }

  /// Ejecuta el análisis predictivo basado en eventos recientes
  Future<List<ThreatPrediction>> runPredictiveAnalysis() async {
    if (!_isInitialized) await initialize();

    try {
      // Obtener eventos recientes para análisis
      final recentEvents = _securityMonitor.getRecentEvents(limit: 1000);

      // Obtener anomalías de comportamiento
      final anomalies = _behaviorAnalysis.getAnomalies(
        since: DateTime.now().subtract(_config.analysisWindow),
      );

      final newPredictions = <ThreatPrediction>[];

      // Análisis de patrones de fuerza bruta
      final bruteForcePrediction = _analyzeBruteForcePattern(recentEvents);
      if (bruteForcePrediction != null) {
        newPredictions.add(bruteForcePrediction);
      }

      // Análisis de patrones de inyección SQL
      final sqlInjectionPrediction = _analyzeSqlInjectionPattern(recentEvents);
      if (sqlInjectionPrediction != null) {
        newPredictions.add(sqlInjectionPrediction);
      }

      // Análisis de patrones DDoS
      final ddosPrediction = _analyzeDdosPattern(recentEvents, anomalies);
      if (ddosPrediction != null) {
        newPredictions.add(ddosPrediction);
      }

      // Análisis de exfiltración de datos
      final exfiltrationPrediction = _analyzeDataExfiltrationPattern(anomalies);
      if (exfiltrationPrediction != null) {
        newPredictions.add(exfiltrationPrediction);
      }

      // Agregar nuevas predicciones
      _predictions.addAll(newPredictions);

      // Limpiar predicciones antiguas
      _cleanOldPredictions();

      // Log del análisis
      await _logger.logSecurityEvent(
        event: 'predictive_analysis_completed',
        level: SecurityLogLevel.info,
        category: SecurityEventCategory.systemIntegrity,
        details: {
          'events_analyzed': recentEvents.length,
          'anomalies_analyzed': anomalies.length,
          'new_predictions': newPredictions.length,
          'total_active_predictions': _predictions.length,
        },
      );

      return newPredictions;
    } catch (e) {
      await _logger.logSecurityEvent(
        event: 'predictive_analysis_error',
        level: SecurityLogLevel.critical,
        category: SecurityEventCategory.systemIntegrity,
        details: {
          'error': e.toString(),
        },
      );
      return [];
    }
  }

  /// Analiza patrones de ataques de fuerza bruta
  ThreatPrediction? _analyzeBruteForcePattern(List<SecurityEvent> events) {
    final loginFailures = events.where((e) => 
      e.type == SecurityEventType.authenticationFailure &&
      e.severity >= 5
    ).toList();

    if (loginFailures.length < 5) return null;

    // Agrupar por IP
    final ipFailures = <String, List<SecurityEvent>>{};
    for (final event in loginFailures) {
      final ip = event.metadata?['client_ip']?.toString() ?? 'unknown';
      ipFailures.putIfAbsent(ip, () => []).add(event);
    }

    // Buscar IPs con muchos fallos
    for (final entry in ipFailures.entries) {
      if (entry.value.length >= 5) {
        final confidence = math.min(0.9, entry.value.length / 20.0 + 0.5);
        
        if (confidence >= _config.minimumConfidence) {
          return ThreatPrediction(
            id: _generateId(),
            type: ThreatType.bruteForce,
            riskLevel: _calculateRiskLevel(confidence),
            confidence: confidence,
            predictedTime: DateTime.now().add(const Duration(minutes: 30)),
            sourceIp: entry.key,
            indicators: {
              'failed_attempts': entry.value.length,
              'time_window_minutes': _config.analysisWindow.inMinutes,
              'pattern': 'repeated_login_failures',
            },
            recommendations: [
              'Bloquear temporalmente la IP ${entry.key}',
              'Implementar CAPTCHA para intentos de login',
              'Activar alertas en tiempo real para esta IP',
              'Revisar logs de acceso para patrones adicionales',
            ],
            createdAt: DateTime.now(),
          );
        }
      }
    }

    return null;
  }

  /// Analiza patrones de inyección SQL
  ThreatPrediction? _analyzeSqlInjectionPattern(List<SecurityEvent> events) {
    final sqlEvents = events.where((e) => 
      e.type == SecurityEventType.maliciousPattern ||
      (e.metadata?.containsKey('sql_keywords') == true && e.severity >= 6)
    ).toList();

    if (sqlEvents.length < 3) return null;

    final confidence = math.min(0.95, sqlEvents.length / 10.0 + 0.6);
    
    if (confidence >= _config.minimumConfidence) {
      return ThreatPrediction(
        id: _generateId(),
        type: ThreatType.sqlInjection,
        riskLevel: _calculateRiskLevel(confidence),
        confidence: confidence,
        predictedTime: DateTime.now().add(const Duration(minutes: 15)),
        indicators: {
          'sql_injection_attempts': sqlEvents.length,
          'pattern': 'escalating_sql_probes',
          'affected_endpoints': sqlEvents.map((e) => e.metadata?['endpoint']).where((e) => e != null).toSet().length,
        },
        recommendations: [
          'Activar WAF con reglas anti-SQL injection',
          'Revisar y sanitizar parámetros de entrada',
          'Implementar prepared statements',
          'Monitorear consultas a base de datos',
        ],
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Analiza patrones de ataques DDoS
  ThreatPrediction? _analyzeDdosPattern(List<SecurityEvent> events, List<BehaviorAnomaly> anomalies) {
    final highVolumeAnomalies = anomalies.where((a) => 
      a.pattern == BehaviorPattern.rapidRequests &&
      a.riskScore >= 7
    ).toList();

    if (highVolumeAnomalies.length < 2) return null;

    final confidence = math.min(0.9, highVolumeAnomalies.length / 5.0 + 0.7);
    
    if (confidence >= _config.minimumConfidence) {
      return ThreatPrediction(
        id: _generateId(),
        type: ThreatType.ddosAttack,
        riskLevel: _calculateRiskLevel(confidence),
        confidence: confidence,
        predictedTime: DateTime.now().add(const Duration(minutes: 10)),
        indicators: {
          'high_volume_anomalies': highVolumeAnomalies.length,
          'pattern': 'coordinated_high_volume_requests',
          'unique_sources': highVolumeAnomalies.map((a) => a.clientId).toSet().length,
        },
        recommendations: [
          'Activar protección DDoS',
          'Implementar rate limiting agresivo',
          'Bloquear IPs sospechosas',
          'Escalar recursos de servidor si es necesario',
        ],
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Analiza patrones de exfiltración de datos
  ThreatPrediction? _analyzeDataExfiltrationPattern(List<BehaviorAnomaly> anomalies) {
    final dataAnomalies = anomalies.where((a) => 
      a.pattern == BehaviorPattern.dataExfiltration &&
      a.riskScore >= 8
    ).toList();

    if (dataAnomalies.isEmpty) return null;

    final confidence = math.min(0.95, dataAnomalies.length / 3.0 + 0.8);
    
    if (confidence >= _config.minimumConfidence) {
      return ThreatPrediction(
        id: _generateId(),
        type: ThreatType.dataExfiltration,
        riskLevel: RiskLevel.critical,
        confidence: confidence,
        predictedTime: DateTime.now().add(const Duration(minutes: 5)),
        indicators: {
          'data_exfiltration_anomalies': dataAnomalies.length,
          'pattern': 'unusual_data_access_patterns',
          'affected_users': dataAnomalies.map((a) => a.userId).where((u) => u != null).toSet().length,
        },
        recommendations: [
          'ALERTA CRÍTICA: Posible exfiltración de datos en curso',
          'Revisar inmediatamente los accesos a datos sensibles',
          'Suspender cuentas sospechosas',
          'Activar protocolos de respuesta a incidentes',
        ],
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Calcula el nivel de riesgo basado en la confianza
  RiskLevel _calculateRiskLevel(double confidence) {
    if (confidence >= 0.9) return RiskLevel.critical;
    if (confidence >= 0.8) return RiskLevel.high;
    if (confidence >= 0.7) return RiskLevel.medium;
    return RiskLevel.low;
  }

  /// Genera un ID único para la predicción
  String _generateId() {
    return 'pred_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
  }

  /// Limpia predicciones antiguas
  void _cleanOldPredictions() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    _predictions.removeWhere((p) => p.createdAt.isBefore(cutoff));
  }

  /// Obtiene todas las predicciones activas
  List<ThreatPrediction> getActivePredictions() {
    return List.unmodifiable(_predictions);
  }

  /// Obtiene predicciones filtradas por tipo
  List<ThreatPrediction> getPredictionsByType(ThreatType type) {
    return _predictions.where((p) => p.type == type).toList();
  }

  /// Obtiene predicciones filtradas por nivel de riesgo
  List<ThreatPrediction> getPredictionsByRiskLevel(RiskLevel riskLevel) {
    return _predictions.where((p) => p.riskLevel == riskLevel).toList();
  }

  /// Obtiene estadísticas de predicciones
  Map<String, dynamic> getPredictionStats() {
    final now = DateTime.now();
    final last24h = _predictions.where((p) => 
      p.createdAt.isAfter(now.subtract(const Duration(hours: 24)))
    ).toList();

    final byType = <String, int>{};
    final byRisk = <String, int>{};
    
    for (final prediction in last24h) {
      final type = prediction.type.toString();
      final risk = prediction.riskLevel.toString();
      byType[type] = (byType[type] ?? 0) + 1;
      byRisk[risk] = (byRisk[risk] ?? 0) + 1;
    }

    return {
      'total_predictions': _predictions.length,
      'predictions_last_24h': last24h.length,
      'by_type': byType,
      'by_risk_level': byRisk,
      'average_confidence': last24h.isEmpty ? 0.0 : 
        last24h.map((p) => p.confidence).reduce((a, b) => a + b) / last24h.length,
    };
  }
}