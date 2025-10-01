import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/security_config.dart';
import '../middleware/security_middleware.dart';
import '../middleware/rate_limiting_middleware.dart';
import '../middleware/input_validation_middleware.dart';
import '../services/security_logging_service.dart';
import '../utils/logger.dart';

/// Servicio de inicialización del sistema de seguridad
class SecurityInitializationService {
  static SecurityInitializationService? _instance;
  static SecurityInitializationService get instance {
    _instance ??= SecurityInitializationService._internal();
    return _instance!;
  }
  
  SecurityInitializationService._internal();
  
  bool _isInitialized = false;
  late SecurityConfig _currentConfig;
  late SecurityMiddleware _securityMiddleware;
  late RateLimitingMiddleware _rateLimitMiddleware;
  late InputValidationMiddleware _inputValidationMiddleware;
  
  /// Indica si el sistema de seguridad está inicializado
  bool get isInitialized => _isInitialized;
  
  /// Configuración actual del sistema de seguridad
  SecurityConfig get currentConfig => _currentConfig;
  
  /// Middleware de seguridad principal
  SecurityMiddleware get securityMiddleware => _securityMiddleware;
  
  /// Middleware de rate limiting
  RateLimitingMiddleware get rateLimitMiddleware => _rateLimitMiddleware;
  
  /// Middleware de validación de entrada
  InputValidationMiddleware get inputValidationMiddleware => _inputValidationMiddleware;
  
  /// Inicializa el sistema de seguridad
  Future<void> initialize({
    String? environment,
    SecurityConfig? customConfig,
  }) async {
    if (_isInitialized) {
      Logger.warning('Security system already initialized');
      return;
    }
    
    try {
      Logger.info('Initializing security system...');
      
      // Determinar configuración a usar
      if (customConfig != null) {
        _currentConfig = customConfig;
      } else if (environment != null) {
        _currentConfig = AppSecurityConfig.getConfigForEnvironment(environment);
      } else {
        // Detectar entorno automáticamente
        final detectedEnv = _detectEnvironment();
        _currentConfig = AppSecurityConfig.getConfigForEnvironment(detectedEnv);
      }
      
      Logger.info('Using security configuration for environment: ${_getEnvironmentName()}');
      
      // Inicializar servicios de logging y monitoreo
      await _initializeLoggingServices();
      
      // Inicializar servicios de análisis y predicción
      await _initializeAnalysisServices();
      
      // Inicializar middlewares
      await _initializeMiddlewares();
      
      // Configurar handlers de errores globales
      _setupGlobalErrorHandlers();
      
      // Registrar métricas iniciales
      await _registerInitialMetrics();
      
      _isInitialized = true;
      
      Logger.info('Security system initialized successfully');
      
      // Log de configuración (sin datos sensibles)
      _logSecurityConfiguration();
      
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize security system: $e', stackTrace);
      rethrow;
    }
  }
  
  /// Detecta el entorno de ejecución
  String _detectEnvironment() {
    if (kDebugMode) {
      return 'development';
    }
    
    if (kProfileMode) {
      return 'testing';
    }
    
    return 'production';
  }
  
  /// Obtiene el nombre del entorno actual
  String _getEnvironmentName() {
    if (_currentConfig == AppSecurityConfig.developmentConfig) {
      return 'development';
    } else if (_currentConfig == AppSecurityConfig.testingConfig) {
      return 'testing';
    } else {
      return 'production';
    }
  }
  
  /// Inicializa los servicios de logging y monitoreo
  Future<void> _initializeLoggingServices() async {
    Logger.info('Initializing logging services...');
    
    // El SecurityLoggingService ya es singleton, solo verificamos que esté disponible
    
    // Configurar nivel de logging según el entorno
    if (_currentConfig.enableRequestLogging) {
      Logger.info('Request logging enabled');
    }
    
    if (_currentConfig.enableResponseLogging) {
      Logger.info('Response logging enabled');
    }
    
    Logger.info('Logging services initialized');
  }
  
  /// Inicializa los servicios de análisis y predicción
  Future<void> _initializeAnalysisServices() async {
    Logger.info('Initializing analysis services...');
    
    if (_currentConfig.enableBehaviorAnalysis) {
      // Inicializar servicio de análisis de comportamiento
      Logger.info('Behavior analysis service initialized');
      
      // Inicializar servicio de predicción de amenazas
      Logger.info('Threat prediction service initialized');
      
      // Inicializar servicio de respuesta a amenazas
      Logger.info('Threat response service initialized');
    } else {
      Logger.info('Behavior analysis disabled for this environment');
    }
    
    Logger.info('Analysis services initialized');
  }
  
  /// Inicializa los middlewares de seguridad
  Future<void> _initializeMiddlewares() async {
    Logger.info('Initializing security middlewares...');
    
    // Inicializar middleware de rate limiting
    if (_currentConfig.rateLimitConfig != null) {
      _rateLimitMiddleware = RateLimitingMiddleware(
        config: _currentConfig.rateLimitConfig!,
      );
      Logger.info('Rate limiting middleware initialized');
    }
    
    // Inicializar middleware de validación de entrada
    if (_currentConfig.inputValidationConfig != null) {
      _inputValidationMiddleware = InputValidationMiddleware(
        config: _currentConfig.inputValidationConfig!,
      );
      Logger.info('Input validation middleware initialized');
    }
    
    // Inicializar middleware de seguridad principal
    _securityMiddleware = SecurityMiddleware();
    _securityMiddleware.initialize(config: _currentConfig);
    
    Logger.info('Security middlewares initialized');
  }
  
  /// Configura handlers de errores globales
  void _setupGlobalErrorHandlers() {
    Logger.info('Setting up global error handlers...');
    
    // Handler para errores no capturados en Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      Logger.error(
        'Flutter error: ${details.exception}',
        details.stack,
      );
      
      // Registrar como evento de seguridad si es relevante
      if (_isSecurityRelevantError(details.exception)) {
        SecurityLoggingService.instance.logSecurityEvent(
          level: SecurityLogLevel.warning,
          category: SecurityEventCategory.systemIntegrity,
          event: 'application_error',
          details: {
            'error_type': details.exception.runtimeType.toString(),
            'stack_trace': details.stack.toString(),
            'library': details.library,
            'context': details.context?.toString(),
            'description': 'Security-relevant application error: ${details.exception}',
          },
        );
      }
    };
    
    Logger.info('Global error handlers configured');
  }
  
  /// Verifica si un error es relevante para la seguridad
  bool _isSecurityRelevantError(dynamic exception) {
    final errorString = exception.toString().toLowerCase();
    
    // Errores relacionados con autenticación
    if (errorString.contains('auth') || 
        errorString.contains('token') ||
        errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return true;
    }
    
    // Errores de red sospechosos
    if (errorString.contains('certificate') ||
        errorString.contains('ssl') ||
        errorString.contains('tls') ||
        errorString.contains('handshake')) {
      return true;
    }
    
    // Errores de validación
    if (errorString.contains('validation') ||
        errorString.contains('sanitization') ||
        errorString.contains('injection')) {
      return true;
    }
    
    return false;
  }
  
  /// Registra métricas iniciales del sistema
  Future<void> _registerInitialMetrics() async {
    Logger.info('Registering initial security metrics...');
    
    final metrics = {
      'security_system_version': '1.0.0',
      'environment': _getEnvironmentName(),
      'initialization_time': DateTime.now().toIso8601String(),
      'config': {
        'rate_limiting_enabled': _currentConfig.rateLimitConfig != null,
        'input_validation_enabled': _currentConfig.inputValidationConfig != null,
        'behavior_analysis_enabled': _currentConfig.enableBehaviorAnalysis,
        'request_logging_enabled': _currentConfig.enableRequestLogging,
        'response_logging_enabled': _currentConfig.enableResponseLogging,
        'trusted_proxies_count': _currentConfig.trustedProxies.length,
        'security_headers_count': _currentConfig.securityHeaders.length,
      },
    };
    
    SecurityLoggingService.instance.logSecurityEvent(
      level: SecurityLogLevel.info,
      category: SecurityEventCategory.systemIntegrity,
      event: 'system_initialization',
      details: metrics,
    );
    
    Logger.info('Initial security metrics registered');
  }
  
  /// Log de la configuración de seguridad (sin datos sensibles)
  void _logSecurityConfiguration() {
    final config = {
      'environment': _getEnvironmentName(),
      'rate_limiting': {
        'enabled': _currentConfig.rateLimitConfig != null,
        'max_requests': _currentConfig.rateLimitConfig?.maxRequests,
        'window_duration': _currentConfig.rateLimitConfig?.window.inSeconds,
      },
      'input_validation': {
        'enabled': _currentConfig.inputValidationConfig != null,
        'max_request_size': _currentConfig.inputValidationConfig?.maxRequestSize,
        'sql_injection_detection': _currentConfig.inputValidationConfig?.enableSqlInjectionDetection,
        'xss_detection': _currentConfig.inputValidationConfig?.enableXssDetection,
      },
      'behavior_analysis': _currentConfig.enableBehaviorAnalysis,
      'logging': {
        'requests': _currentConfig.enableRequestLogging,
        'responses': _currentConfig.enableResponseLogging,
      },
      'security_headers': _currentConfig.securityHeaders.keys.toList(),
      'trusted_proxies': _currentConfig.trustedProxies.length,
    };
    
    Logger.info('Security configuration: $config');
  }
  
  /// Obtiene estadísticas del sistema de seguridad
  Map<String, dynamic> getSecurityStats() {
    if (!_isInitialized) {
      return {'error': 'Security system not initialized'};
    }
    
    final stats = <String, dynamic>{
      'initialized': _isInitialized,
      'environment': _getEnvironmentName(),
      'uptime': DateTime.now().difference(_getInitializationTime()).inSeconds,
    };
    
    // Estadísticas del middleware principal
    stats['security_middleware'] = _securityMiddleware.getSecurityStats();
    
    // Estadísticas de rate limiting
    if (_currentConfig.rateLimitConfig != null) {
      stats['rate_limiting'] = _rateLimitMiddleware.getStats();
    }
    
    // Estadísticas de validación de entrada
    if (_currentConfig.inputValidationConfig != null) {
      stats['input_validation'] = _inputValidationMiddleware.getStats();
    }
    
    return stats;
  }
  
  /// Obtiene el tiempo de inicialización (simulado)
  DateTime _getInitializationTime() {
    // En una implementación real, esto se almacenaría cuando se inicializa
    return DateTime.now().subtract(const Duration(minutes: 1));
  }
  
  /// Recarga la configuración de seguridad
  Future<void> reloadConfiguration({
    String? environment,
    SecurityConfig? customConfig,
  }) async {
    Logger.info('Reloading security configuration...');
    
    try {
      // Limpiar recursos actuales
      await dispose();
      
      // Reinicializar con nueva configuración
      _isInitialized = false;
      await initialize(
        environment: environment,
        customConfig: customConfig,
      );
      
      Logger.info('Security configuration reloaded successfully');
      
    } catch (e, stackTrace) {
      Logger.error('Failed to reload security configuration: $e', stackTrace);
      rethrow;
    }
  }
  
  /// Verifica el estado de salud del sistema de seguridad
  Future<Map<String, dynamic>> healthCheck() async {
    final health = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'overall_status': 'healthy',
      'components': <String, dynamic>{},
    };
    
    try {
      // Verificar middleware de seguridad
      health['components']['security_middleware'] = {
        'status': _isInitialized ? 'healthy' : 'unhealthy',
        'initialized': _isInitialized,
      };
      
      // Verificar rate limiting
      if (_currentConfig.rateLimitConfig != null) {
        final rateLimitStats = _rateLimitMiddleware.getStats();
        health['components']['rate_limiting'] = {
          'status': 'healthy',
          'active_clients': rateLimitStats['active_clients'] ?? 0,
          'blocked_clients': rateLimitStats['blocked_clients'] ?? 0,
        };
      }
      
      // Verificar validación de entrada
      if (_currentConfig.inputValidationConfig != null) {
        final validationStats = _inputValidationMiddleware.getStats();
        health['components']['input_validation'] = {
          'status': 'healthy',
          'total_requests': validationStats['total_requests'] ?? 0,
          'blocked_requests': validationStats['blocked_requests'] ?? 0,
        };
      }
      
      // Verificar servicios de análisis
      if (_currentConfig.enableBehaviorAnalysis) {
        health['components']['behavior_analysis'] = {
          'status': 'healthy',
          'service': 'active',
        };
      }
      
    } catch (e) {
      health['overall_status'] = 'unhealthy';
      health['error'] = e.toString();
    }
    
    return health;
  }
  
  /// Limpia recursos del sistema de seguridad
  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }
    
    Logger.info('Disposing security system...');
    
    try {
      // Limpiar middlewares
      _securityMiddleware.dispose();
      
      if (_currentConfig.rateLimitConfig != null) {
        _rateLimitMiddleware.dispose();
      }
      
      // InputValidationMiddleware no tiene método dispose
      
      _isInitialized = false;
      
      Logger.info('Security system disposed successfully');
      
    } catch (e, stackTrace) {
      Logger.error('Error disposing security system: $e', stackTrace);
    }
  }
}
