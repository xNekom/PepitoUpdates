import 'dart:async';
import 'dart:math';
import '../utils/logger.dart';
import 'security_monitor_service.dart';

/// Tipos de patrones de comportamiento anómalos
enum BehaviorPattern {
  rapidRequests,
  unusualEndpoints,
  suspiciousUserAgent,
  geolocationAnomaly,
  timeBasedAnomaly,
  dataExfiltration,
  bruteForceAttempt,
  sessionHijacking,
}

/// Modelo para una anomalía detectada
class BehaviorAnomaly {
  final String id;
  final BehaviorPattern pattern;
  final String description;
  final double riskScore;
  final DateTime detectedAt;
  final String? userId;
  final String? clientId;
  final String? endpoint;
  final Map<String, dynamic> metadata;
  final List<String> indicators;

  BehaviorAnomaly({
    required this.id,
    required this.pattern,
    required this.description,
    required this.riskScore,
    required this.detectedAt,
    this.userId,
    this.clientId,
    this.endpoint,
    this.metadata = const {},
    this.indicators = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'pattern': pattern.name,
    'description': description,
    'riskScore': riskScore,
    'detectedAt': detectedAt.toIso8601String(),
    'userId': userId,
    'clientId': clientId,
    'endpoint': endpoint,
    'metadata': metadata,
    'indicators': indicators,
  };
}

/// Modelo para el perfil de comportamiento de un usuario
class UserBehaviorProfile {
  final String userId;
  final Map<String, int> endpointFrequency;
  final Map<String, double> requestTiming;
  final Set<String> commonUserAgents;
  final Set<String> commonIpAddresses;
  final DateTime lastUpdated;
  final int totalRequests;
  final double averageRequestsPerHour;

  UserBehaviorProfile({
    required this.userId,
    required this.endpointFrequency,
    required this.requestTiming,
    required this.commonUserAgents,
    required this.commonIpAddresses,
    required this.lastUpdated,
    required this.totalRequests,
    required this.averageRequestsPerHour,
  });
}

/// Configuración para el análisis de comportamiento
class BehaviorAnalysisConfig {
  final double rapidRequestsThreshold;
  final Duration rapidRequestsWindow;
  final double riskScoreThreshold;
  final int maxAnomaliesStored;
  final Duration profileUpdateInterval;
  final bool enableRealTimeAnalysis;
  final bool enableMachineLearning;

  const BehaviorAnalysisConfig({
    this.rapidRequestsThreshold = 10.0,
    this.rapidRequestsWindow = const Duration(minutes: 1),
    this.riskScoreThreshold = 7.0,
    this.maxAnomaliesStored = 1000,
    this.profileUpdateInterval = const Duration(hours: 1),
    this.enableRealTimeAnalysis = true,
    this.enableMachineLearning = false,
  });
}

/// Servicio de análisis de comportamiento para detección de anomalías
class BehaviorAnalysisService {
  static final BehaviorAnalysisService _instance = BehaviorAnalysisService._internal();
  static BehaviorAnalysisService get instance => _instance;
  BehaviorAnalysisService._internal();

  final BehaviorAnalysisConfig _config = const BehaviorAnalysisConfig();
  final List<BehaviorAnomaly> _detectedAnomalies = [];
  final Map<String, UserBehaviorProfile> _userProfiles = {};
  final Map<String, List<DateTime>> _requestHistory = {};
  final StreamController<BehaviorAnomaly> _anomalyController = StreamController<BehaviorAnomaly>.broadcast();
  
  Timer? _profileUpdateTimer;
  bool _isInitialized = false;

  /// Stream de anomalías detectadas en tiempo real
  Stream<BehaviorAnomaly> get anomalyStream => _anomalyController.stream;

  /// Inicializar el servicio de análisis de comportamiento
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      Logger.info('Inicializando servicio de análisis de comportamiento');
      
      // Configurar actualizaciones periódicas de perfiles
      _profileUpdateTimer = Timer.periodic(
        _config.profileUpdateInterval,
        (_) => _updateUserProfiles(),
      );

      _isInitialized = true;
      Logger.info('Servicio de análisis de comportamiento inicializado');
    } catch (e) {
      Logger.error('Error inicializando análisis de comportamiento', e);
      rethrow;
    }
  }

  /// Analizar una solicitud para detectar anomalías
  Future<void> analyzeRequest({
    required String endpoint,
    required String method,
    required String clientId,
    String? userId,
    String? userAgent,
    String? ipAddress,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body,
  }) async {
    if (!_isInitialized) return;

    try {
      final now = DateTime.now();
      final requestKey = '${clientId}_${userId ?? "anonymous"}';
      
      // Registrar la solicitud
      _requestHistory.putIfAbsent(requestKey, () => []).add(now);
      
      // Limpiar historial antiguo (últimas 24 horas)
      final cutoff = now.subtract(const Duration(hours: 24));
      _requestHistory[requestKey]?.removeWhere((time) => time.isBefore(cutoff));

      // Análisis de patrones
      await _analyzeRapidRequests(requestKey, endpoint, clientId, userId);
      await _analyzeUnusualEndpoints(endpoint, userId, clientId);
      await _analyzeSuspiciousUserAgent(userAgent, clientId, userId);
      await _analyzeTimeBasedAnomalies(now, userId, clientId, endpoint);
      
      if (body != null) {
        await _analyzeDataExfiltration(body, endpoint, userId, clientId);
      }

      // Actualizar perfil del usuario si está disponible
      if (userId != null) {
        await _updateUserProfile(userId, endpoint, now, userAgent, ipAddress);
      }
    } catch (e) {
      Logger.error('Error analizando solicitud', e);
    }
  }

  /// Analizar solicitudes rápidas consecutivas
  Future<void> _analyzeRapidRequests(String requestKey, String endpoint, String clientId, String? userId) async {
    final requests = _requestHistory[requestKey] ?? [];
    if (requests.length < 2) return;

    final now = DateTime.now();
    final recentRequests = requests.where(
      (time) => now.difference(time) <= _config.rapidRequestsWindow,
    ).length;

    if (recentRequests > _config.rapidRequestsThreshold) {
      final anomaly = BehaviorAnomaly(
        id: _generateAnomalyId(),
        pattern: BehaviorPattern.rapidRequests,
        description: 'Solicitudes rápidas detectadas: $recentRequests en ${_config.rapidRequestsWindow.inMinutes} minutos',
        riskScore: _calculateRiskScore(recentRequests.toDouble(), _config.rapidRequestsThreshold.toDouble()),
        detectedAt: now,
        userId: userId,
        clientId: clientId,
        endpoint: endpoint,
        metadata: {
          'requestCount': recentRequests,
          'timeWindow': _config.rapidRequestsWindow.inMinutes,
          'threshold': _config.rapidRequestsThreshold,
        },
        indicators: ['high_frequency_requests', 'potential_dos_attack'],
      );

      await _reportAnomaly(anomaly);
    }
  }

  /// Analizar endpoints inusuales
  Future<void> _analyzeUnusualEndpoints(String endpoint, String? userId, String clientId) async {
    if (userId == null) return;

    final profile = _userProfiles[userId];
    if (profile == null) return;

    final endpointFrequency = profile.endpointFrequency[endpoint] ?? 0;
    final totalRequests = profile.totalRequests;
    
    if (totalRequests > 50 && endpointFrequency == 0) {
      final anomaly = BehaviorAnomaly(
        id: _generateAnomalyId(),
        pattern: BehaviorPattern.unusualEndpoints,
        description: 'Acceso a endpoint inusual: $endpoint',
        riskScore: 6.0,
        detectedAt: DateTime.now(),
        userId: userId,
        clientId: clientId,
        endpoint: endpoint,
        metadata: {
          'userTotalRequests': totalRequests,
          'endpointFrequency': endpointFrequency,
        },
        indicators: ['unusual_endpoint_access', 'potential_reconnaissance'],
      );

      await _reportAnomaly(anomaly);
    }
  }

  /// Analizar User-Agent sospechoso
  Future<void> _analyzeSuspiciousUserAgent(String? userAgent, String clientId, String? userId) async {
    if (userAgent == null) return;

    final suspiciousPatterns = [
      'bot', 'crawler', 'spider', 'scraper', 'curl', 'wget', 'python', 'java',
      'automated', 'script', 'tool', 'scanner', 'test'
    ];

    final isSuspicious = suspiciousPatterns.any(
      (pattern) => userAgent.toLowerCase().contains(pattern),
    );

    if (isSuspicious) {
      final anomaly = BehaviorAnomaly(
        id: _generateAnomalyId(),
        pattern: BehaviorPattern.suspiciousUserAgent,
        description: 'User-Agent sospechoso detectado: $userAgent',
        riskScore: 5.0,
        detectedAt: DateTime.now(),
        userId: userId,
        clientId: clientId,
        metadata: {
          'userAgent': userAgent,
          'suspiciousPatterns': suspiciousPatterns.where(
            (pattern) => userAgent.toLowerCase().contains(pattern),
          ).toList(),
        },
        indicators: ['suspicious_user_agent', 'potential_automation'],
      );

      await _reportAnomaly(anomaly);
    }
  }

  /// Analizar anomalías basadas en tiempo
  Future<void> _analyzeTimeBasedAnomalies(DateTime requestTime, String? userId, String clientId, String endpoint) async {
    if (userId == null) return;

    final profile = _userProfiles[userId];
    if (profile == null) return;

    final hour = requestTime.hour;
    final isUnusualTime = hour < 6 || hour > 22; // Fuera del horario normal

    if (isUnusualTime && profile.totalRequests > 100) {
      final anomaly = BehaviorAnomaly(
        id: _generateAnomalyId(),
        pattern: BehaviorPattern.timeBasedAnomaly,
        description: 'Actividad en horario inusual: $hour:${requestTime.minute.toString().padLeft(2, '0')}',
        riskScore: 4.0,
        detectedAt: requestTime,
        userId: userId,
        clientId: clientId,
        endpoint: endpoint,
        metadata: {
          'requestHour': hour,
          'requestMinute': requestTime.minute,
          'userTotalRequests': profile.totalRequests,
        },
        indicators: ['unusual_time_access', 'potential_unauthorized_access'],
      );

      await _reportAnomaly(anomaly);
    }
  }

  /// Analizar posible exfiltración de datos
  Future<void> _analyzeDataExfiltration(Map<String, dynamic> body, String endpoint, String? userId, String clientId) async {
    final bodySize = body.toString().length;
    final isLargeRequest = bodySize > 10000; // Más de 10KB
    
    final sensitiveEndpoints = ['/export', '/download', '/backup', '/data'];
    final isSensitiveEndpoint = sensitiveEndpoints.any(
      (sensitive) => endpoint.contains(sensitive),
    );

    if (isLargeRequest && isSensitiveEndpoint) {
      final anomaly = BehaviorAnomaly(
        id: _generateAnomalyId(),
        pattern: BehaviorPattern.dataExfiltration,
        description: 'Posible exfiltración de datos detectada en $endpoint',
        riskScore: 8.0,
        detectedAt: DateTime.now(),
        userId: userId,
        clientId: clientId,
        endpoint: endpoint,
        metadata: {
          'bodySize': bodySize,
          'endpoint': endpoint,
          'sensitiveEndpoint': true,
        },
        indicators: ['large_data_transfer', 'sensitive_endpoint', 'potential_data_exfiltration'],
      );

      await _reportAnomaly(anomaly);
    }
  }

  /// Actualizar perfil de comportamiento del usuario
  Future<void> _updateUserProfile(String userId, String endpoint, DateTime requestTime, String? userAgent, String? ipAddress) async {
    final existing = _userProfiles[userId];
    final now = DateTime.now();

    if (existing == null) {
      _userProfiles[userId] = UserBehaviorProfile(
        userId: userId,
        endpointFrequency: {endpoint: 1},
        requestTiming: {requestTime.hour.toString(): 1.0},
        commonUserAgents: userAgent != null ? {userAgent} : {},
        commonIpAddresses: ipAddress != null ? {ipAddress} : {},
        lastUpdated: now,
        totalRequests: 1,
        averageRequestsPerHour: 1.0,
      );
    } else {
      final endpointFreq = Map<String, int>.from(existing.endpointFrequency);
      endpointFreq[endpoint] = (endpointFreq[endpoint] ?? 0) + 1;

      final requestTiming = Map<String, double>.from(existing.requestTiming);
      final hourKey = requestTime.hour.toString();
      requestTiming[hourKey] = (requestTiming[hourKey] ?? 0.0) + 1.0;

      final userAgents = Set<String>.from(existing.commonUserAgents);
      if (userAgent != null) userAgents.add(userAgent);

      final ipAddresses = Set<String>.from(existing.commonIpAddresses);
      if (ipAddress != null) ipAddresses.add(ipAddress);

      final totalRequests = existing.totalRequests + 1;
      final hoursSinceFirst = now.difference(existing.lastUpdated).inHours.clamp(1, 24 * 30);
      final averageRequestsPerHour = totalRequests / hoursSinceFirst;

      _userProfiles[userId] = UserBehaviorProfile(
        userId: userId,
        endpointFrequency: endpointFreq,
        requestTiming: requestTiming,
        commonUserAgents: userAgents,
        commonIpAddresses: ipAddresses,
        lastUpdated: now,
        totalRequests: totalRequests,
        averageRequestsPerHour: averageRequestsPerHour,
      );
    }
  }

  /// Actualizar todos los perfiles de usuario
  Future<void> _updateUserProfiles() async {
    try {
      Logger.info('Actualizando perfiles de comportamiento de usuarios');
      
      // Limpiar perfiles antiguos (más de 30 días sin actividad)
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      _userProfiles.removeWhere((key, profile) => profile.lastUpdated.isBefore(cutoff));
      
      Logger.info('Perfiles actualizados: ${_userProfiles.length} usuarios activos');
    } catch (e) {
      Logger.error('Error actualizando perfiles de usuario', e);
    }
  }

  /// Reportar una anomalía detectada
  Future<void> _reportAnomaly(BehaviorAnomaly anomaly) async {
    try {
      _detectedAnomalies.add(anomaly);
      
      // Mantener solo las anomalías más recientes
      if (_detectedAnomalies.length > _config.maxAnomaliesStored) {
        _detectedAnomalies.removeAt(0);
      }

      // Emitir evento en tiempo real
      _anomalyController.add(anomaly);

      // Reportar al sistema de monitoreo si es de alto riesgo
      if (anomaly.riskScore >= _config.riskScoreThreshold) {
        SecurityMonitorService().logSecurityEvent(SecurityEvent(
          type: SecurityEventType.suspiciousActivity,
          message: 'Anomalía de comportamiento detectada: ${anomaly.description}',
          severity: anomaly.riskScore.round(),
          userId: anomaly.userId,
          clientId: anomaly.clientId,
          endpoint: anomaly.endpoint,
          metadata: {
            'anomalyId': anomaly.id,
            'pattern': anomaly.pattern.name,
            'riskScore': anomaly.riskScore,
            'indicators': anomaly.indicators,
            ...anomaly.metadata,
          },
        ));
      }

      Logger.warning(
        'Anomalía de comportamiento detectada: ${anomaly.pattern.name} - ${anomaly.description}',
      );
    } catch (e) {
      Logger.error('Error reportando anomalía', e);
    }
  }

  /// Obtener anomalías detectadas
  List<BehaviorAnomaly> getAnomalies({
    BehaviorPattern? pattern,
    double? minRiskScore,
    DateTime? since,
    int? limit,
  }) {
    var filtered = List<BehaviorAnomaly>.from(_detectedAnomalies);

    if (pattern != null) {
      filtered = filtered.where((a) => a.pattern == pattern).toList();
    }

    if (minRiskScore != null) {
      filtered = filtered.where((a) => a.riskScore >= minRiskScore).toList();
    }

    if (since != null) {
      filtered = filtered.where((a) => a.detectedAt.isAfter(since)).toList();
    }

    // Ordenar por fecha (más recientes primero)
    filtered.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

    if (limit != null && filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }

    return filtered;
  }

  /// Obtener perfil de comportamiento de un usuario
  UserBehaviorProfile? getUserProfile(String userId) {
    return _userProfiles[userId];
  }

  /// Obtener estadísticas de análisis de comportamiento
  Map<String, dynamic> getAnalysisStats() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    final last7d = now.subtract(const Duration(days: 7));

    final anomaliesLast24h = _detectedAnomalies.where(
      (a) => a.detectedAt.isAfter(last24h),
    ).length;

    final anomaliesLast7d = _detectedAnomalies.where(
      (a) => a.detectedAt.isAfter(last7d),
    ).length;

    final highRiskAnomalies = _detectedAnomalies.where(
      (a) => a.riskScore >= _config.riskScoreThreshold,
    ).length;

    final patternCounts = <String, int>{};
    for (final anomaly in _detectedAnomalies) {
      patternCounts[anomaly.pattern.name] = (patternCounts[anomaly.pattern.name] ?? 0) + 1;
    }

    return {
      'totalAnomalies': _detectedAnomalies.length,
      'anomaliesLast24h': anomaliesLast24h,
      'anomaliesLast7d': anomaliesLast7d,
      'highRiskAnomalies': highRiskAnomalies,
      'activeUserProfiles': _userProfiles.length,
      'patternCounts': patternCounts,
      'averageRiskScore': _detectedAnomalies.isEmpty
          ? 0.0
          : _detectedAnomalies.map((a) => a.riskScore).reduce((a, b) => a + b) / _detectedAnomalies.length,
      'configThreshold': _config.riskScoreThreshold,
    };
  }

  /// Limpiar anomalías antiguas
  Future<void> cleanupOldAnomalies({Duration? olderThan}) async {
    final cutoff = DateTime.now().subtract(olderThan ?? const Duration(days: 30));
    
    final initialCount = _detectedAnomalies.length;
    _detectedAnomalies.removeWhere((anomaly) => anomaly.detectedAt.isBefore(cutoff));
    
    final removedCount = initialCount - _detectedAnomalies.length;
    if (removedCount > 0) {
      Logger.info('Limpieza de anomalías: $removedCount anomalías eliminadas');
    }
  }

  /// Generar ID único para anomalía
  String _generateAnomalyId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'anomaly_${timestamp}_$random';
  }

  /// Calcular puntuación de riesgo
  double _calculateRiskScore(double actual, double threshold) {
    final ratio = actual / threshold;
    return (ratio * 5.0).clamp(1.0, 10.0);
  }

  /// Liberar recursos
  void dispose() {
    _profileUpdateTimer?.cancel();
    _anomalyController.close();
    _detectedAnomalies.clear();
    _userProfiles.clear();
    _requestHistory.clear();
    _isInitialized = false;
  }
}
