import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/logger.dart';
import '../config/environment_config.dart';
import '../services/security_monitor_service.dart';
import '../services/security_logging_service.dart';
import '../services/behavior_analysis_service.dart';
import 'rate_limiting_middleware.dart';
import 'input_validation_middleware.dart';

/// Configuración del middleware de seguridad
class SecurityConfig {
  final RateLimitConfig? rateLimitConfig;
  final InputValidationConfig? inputValidationConfig;
  final bool enableBehaviorAnalysis;
  final bool enableRequestLogging;
  final bool enableResponseLogging;
  final List<String> trustedProxies;
  final Map<String, String> securityHeaders;
  
  const SecurityConfig({
    this.rateLimitConfig,
    this.inputValidationConfig,
    this.enableBehaviorAnalysis = true,
    this.enableRequestLogging = true,
    this.enableResponseLogging = true,
    this.trustedProxies = const [],
    this.securityHeaders = const {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'Referrer-Policy': 'strict-origin-when-cross-origin',
    },
  });
}

/// Middleware de seguridad para validación y sanitización de datos
class SecurityMiddleware {
  static final SecurityMiddleware _instance = SecurityMiddleware._internal();
  factory SecurityMiddleware() => _instance;
  SecurityMiddleware._internal();
  
  final SecurityConfig _config = const SecurityConfig();
  final BehaviorAnalysisService _behaviorAnalysis = BehaviorAnalysisService.instance;
  RateLimitingMiddleware? _rateLimitMiddleware;
  InputValidationMiddleware? _inputValidationMiddleware;
  
  /// Inicializa los middlewares con configuración
  void initialize({SecurityConfig? config}) {
    final finalConfig = config ?? _config;
    
    if (finalConfig.rateLimitConfig != null) {
      _rateLimitMiddleware = RateLimitingMiddleware(config: finalConfig.rateLimitConfig!);
    }
    
    if (finalConfig.inputValidationConfig != null) {
      _inputValidationMiddleware = InputValidationMiddleware(config: finalConfig.inputValidationConfig!);
    }
  }

  /// Valida y sanitiza datos de entrada
  Map<String, dynamic> validateAndSanitizeInput(Map<String, dynamic> data) {
    final sanitizedData = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final key = _sanitizeKey(entry.key);
      final value = _sanitizeValue(entry.value);
      
      if (_isValidKey(key) && _isValidValue(value)) {
        sanitizedData[key] = value;
      } else {
        Logger.warning('Datos inválidos filtrados: $key');
      }
    }
    
    return sanitizedData;
  }
  
  /// Sanitiza una clave
  String _sanitizeKey(String key) {
    // Remover caracteres peligrosos
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '')
              .toLowerCase()
              .trim();
  }
  
  /// Sanitiza un valor
  dynamic _sanitizeValue(dynamic value) {
    if (value is String) {
      return _sanitizeString(value);
    } else if (value is Map) {
      return validateAndSanitizeInput(Map<String, dynamic>.from(value));
    } else if (value is List) {
      return value.map((item) => _sanitizeValue(item)).toList();
    }
    return value;
  }
  
  /// Sanitiza una cadena de texto
  String _sanitizeString(String input) {
    // Remover caracteres de control y scripts maliciosos
    String sanitized = input
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Caracteres de control
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '') // Scripts
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '') // JavaScript URLs
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '') // Event handlers
        .trim();
    
    // Limitar longitud
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
      Logger.warning('Cadena truncada por exceder límite de longitud');
    }
    
    return sanitized;
  }
  
  /// Valida si una clave es válida
  bool _isValidKey(String key) {
    if (key.isEmpty || key.length > 50) return false;
    
    // Lista de claves prohibidas
    const forbiddenKeys = [
      'password', 'secret', 'token', 'key', 'auth',
      'admin', 'root', 'system', 'config'
    ];
    
    return !forbiddenKeys.any((forbidden) => key.contains(forbidden));
  }
  
  /// Valida si un valor es válido
  bool _isValidValue(dynamic value) {
    if (value == null) return true;
    
    if (value is String) {
      // Detectar patrones maliciosos
      final maliciousPatterns = [
        RegExp(r'<script', caseSensitive: false),
        RegExp(r'javascript:', caseSensitive: false),
        RegExp(r'data:text/html', caseSensitive: false),
        RegExp(r'vbscript:', caseSensitive: false),
        RegExp(r'onload\s*=', caseSensitive: false),
        RegExp(r'onerror\s*=', caseSensitive: false),
      ];
      
      return !maliciousPatterns.any((pattern) => pattern.hasMatch(value));
    }
    
    return true;
  }
  
  /// Valida headers de seguridad
  bool validateSecurityHeaders(Map<String, dynamic> headers) {
    final requiredHeaders = [
      'x-request-id',
      'x-client-platform',
      'x-app-version',
    ];
    
    for (final header in requiredHeaders) {
      if (!headers.containsKey(header) && !headers.containsKey(header.toLowerCase())) {
        Logger.warning('Header de seguridad faltante: $header');
        return false;
      }
    }
    
    return true;
  }
  
  /// Valida la integridad de una petición
  bool validateRequestIntegrity(RequestOptions options) {
    try {
      // Validar URL
      if (!_isValidUrl(options.uri.toString())) {
        Logger.error('URL inválida detectada: ${options.uri}');
        return false;
      }
      
      // Validar método HTTP
      if (!_isValidHttpMethod(options.method)) {
        Logger.error('Método HTTP inválido: ${options.method}');
        return false;
      }
      
      // Validar tamaño de datos
      if (options.data != null) {
        final dataSize = _calculateDataSize(options.data);
        if (dataSize > 1024 * 1024) { // 1MB límite
          Logger.error('Datos de petición exceden límite de tamaño: ${dataSize}B');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      Logger.error('Error validando integridad de petición', e);
      return false;
    }
  }
  
  /// Valida si una URL es segura
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // En producción, solo HTTPS
      if (EnvironmentConfig.isProduction && uri.scheme != 'https') {
        return false;
      }
      
      // Validar dominio
      if (uri.host.isEmpty) {
        return false;
      }
      
      // Bloquear IPs privadas en producción
      if (EnvironmentConfig.isProduction && _isPrivateIP(uri.host)) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Verifica si una IP es privada
  bool _isPrivateIP(String host) {
    try {
      final ip = InternetAddress(host);
      return ip.isLoopback || 
             host.startsWith('192.168.') ||
             host.startsWith('10.') ||
             host.startsWith('172.');
    } catch (e) {
      return false; // No es una IP
    }
  }
  
  /// Valida método HTTP
  bool _isValidHttpMethod(String method) {
    const validMethods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS'];
    return validMethods.contains(method.toUpperCase());
  }
  
  /// Calcula el tamaño de los datos
  int _calculateDataSize(dynamic data) {
    if (data == null) return 0;
    
    if (data is String) {
      return utf8.encode(data).length;
    } else if (data is Map || data is List) {
      return utf8.encode(jsonEncode(data)).length;
    }
    
    return data.toString().length;
  }
  
  /// Genera un token CSRF
  String generateCSRFToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 31) % 1000000;
    return '${timestamp}_$random'.hashCode.abs().toString();
  }
  
  /// Valida un token CSRF
  bool validateCSRFToken(String token, {Duration maxAge = const Duration(hours: 1)}) {
    try {
      final parts = token.split('_');
      if (parts.length != 2) return false;
      
      final timestamp = int.parse(parts[0]);
      final tokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      return DateTime.now().difference(tokenTime) <= maxAge;
    } catch (e) {
      return false;
    }
  }
  
  /// Procesa una request a través de todos los middlewares de seguridad
  Future<void> processRequest(RequestOptions options) async {
    // Validación de entrada si está configurada
    if (_inputValidationMiddleware != null) {
      // Validación se hace en el interceptor
    }
    
    // Rate limiting si está configurado
    if (_rateLimitMiddleware != null) {
      // Rate limiting se hace en el interceptor
    }
    
    // Análisis de comportamiento
    if (_config.enableBehaviorAnalysis) {
      await _behaviorAnalysis.analyzeRequest(
        endpoint: options.path,
        method: options.method,
        clientId: _getClientId(options),
        userId: _getUserId(options),
        userAgent: options.headers['User-Agent']?.toString(),
        ipAddress: _getIpAddress(options),
        headers: Map<String, dynamic>.from(options.headers),
        body: options.data is Map ? Map<String, dynamic>.from(options.data) : null,
      );
    }
  }
  
  /// Obtiene el ID del cliente desde headers
  String _getClientId(RequestOptions options) {
    return options.headers['X-Client-ID']?.toString() ?? 'unknown';
  }
  
  /// Obtiene el ID del usuario desde headers
  String? _getUserId(RequestOptions options) {
    return options.headers['X-User-ID']?.toString();
  }
  
  /// Obtiene la dirección IP del cliente
  String _getIpAddress(RequestOptions options) {
    return options.headers['X-Forwarded-For']?.toString() ?? 
           options.headers['X-Real-IP']?.toString() ?? 
           'unknown';
  }
  
  /// Obtiene estadísticas de seguridad
  Map<String, dynamic> getSecurityStats() {
    final stats = <String, dynamic>{
      'config': {
        'behavior_analysis_enabled': _config.enableBehaviorAnalysis,
        'request_logging_enabled': _config.enableRequestLogging,
        'response_logging_enabled': _config.enableResponseLogging,
        'trusted_proxies': _config.trustedProxies.length,
        'security_headers': _config.securityHeaders.length,
      },
    };
    
    if (_rateLimitMiddleware != null) {
      stats['rate_limiting'] = _rateLimitMiddleware!.getStats();
    }
    
    if (_inputValidationMiddleware != null) {
      stats['input_validation'] = _inputValidationMiddleware!.getStats();
    }
    
    return stats;
  }
  
  /// Limpia recursos
  void dispose() {
    _rateLimitMiddleware?.dispose();
  }
}

/// Interceptor de validación de entrada
class InputValidationInterceptor extends Interceptor {
  final SecurityMiddleware _security = SecurityMiddleware();
  final SecurityMonitorService _securityMonitor = SecurityMonitorService();
  final SecurityLoggingService _securityLogger = SecurityLoggingService.instance;
  final BehaviorAnalysisService _behaviorAnalysis = BehaviorAnalysisService.instance;
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // Validar integridad de la petición
      if (!_security.validateRequestIntegrity(options)) {
        _securityMonitor.logSecurityEvent(SecurityEvent(
          type: SecurityEventType.dataValidationFailure,
          message: 'Integridad de petición comprometida en ${options.path}',
          severity: 8,
          endpoint: options.path,
          clientId: options.headers['X-Client-ID']?.toString(),
          metadata: {
            'method': options.method,
            'uri': options.uri.toString(),
          },
        ));
        
        _securityLogger.logSecurityEvent(
          level: SecurityLogLevel.critical,
          category: SecurityEventCategory.networkSecurity,
          event: 'request_integrity_validation_failed',
          details: {
            'endpoint': options.path,
            'method': options.method,
            'uri': options.uri.toString(),
          },
        );
        
        // Análisis de comportamiento
        _behaviorAnalysis.analyzeRequest(
          endpoint: options.path,
          method: options.method,
          clientId: options.headers['X-Client-ID']?.toString() ?? 'unknown',
          userId: options.headers['X-User-ID']?.toString(),
          userAgent: options.headers['User-Agent']?.toString(),
          ipAddress: options.headers['X-Forwarded-For']?.toString(),
          headers: Map<String, dynamic>.from(options.headers),
          body: options.data is Map ? Map<String, dynamic>.from(options.data) : null,
        );
        
        throw DioException(
          requestOptions: options,
          error: 'Request integrity validation failed',
          type: DioExceptionType.badResponse,
        );
      }
      
      // Validar y sanitizar datos
      if (options.data is Map<String, dynamic>) {
        final originalData = options.data;
        options.data = _security.validateAndSanitizeInput(
          Map<String, dynamic>.from(options.data)
        );
        
        // Registrar si se detectaron datos maliciosos
        if (originalData != options.data) {
          _securityMonitor.logSecurityEvent(SecurityEvent(
            type: SecurityEventType.invalidInput,
            message: 'Datos de entrada sanitizados en ${options.path}',
            severity: 4,
            endpoint: options.path,
            clientId: options.headers['X-Client-ID']?.toString(),
            metadata: {
              'method': options.method,
              'data_modified': true,
            },
          ));
          
          _securityLogger.logSecurityEvent(
            level: SecurityLogLevel.warning,
            category: SecurityEventCategory.dataAccess,
            event: 'input_data_sanitized',
            details: {
              'endpoint': options.path,
              'method': options.method,
              'data_modified': true,
            },
          );
        }
      }
      
      // Validar headers de seguridad
      if (!_security.validateSecurityHeaders(options.headers)) {
        _securityMonitor.logSecurityEvent(SecurityEvent(
          type: SecurityEventType.securityHeaderMissing,
          message: 'Headers de seguridad incompletos en petición',
          severity: 6,
          endpoint: options.path,
          clientId: options.headers['X-Client-ID']?.toString(),
          metadata: {
            'method': options.method,
            'headers': options.headers.keys.toList(),
          },
        ));
        
        Logger.warning('Headers de seguridad incompletos en petición');
      }
      
      Logger.info('Validación de entrada completada para ${options.path}');
      handler.next(options);
    } catch (e) {
      Logger.error('Error en validación de entrada', e);
      
      _securityMonitor.logSecurityEvent(SecurityEvent(
        type: SecurityEventType.invalidInput,
        message: 'Error en validación de entrada: $e',
        severity: 7,
        endpoint: options.path,
        clientId: options.headers['X-Client-ID']?.toString(),
        metadata: {
          'error': e.toString(),
          'method': options.method,
        },
      ));
      
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Input validation failed: $e',
          type: DioExceptionType.badResponse,
        ),
      );
    }
  }
}

/// Interceptor de validación de respuesta
class ResponseValidationInterceptor extends Interceptor {
  final SecurityMiddleware _securityMiddleware;
  final SecurityMonitorService _securityMonitor;
  final SecurityLoggingService _securityLogger = SecurityLoggingService.instance;
  final BehaviorAnalysisService _behaviorAnalysis = BehaviorAnalysisService.instance;
  
  ResponseValidationInterceptor(this._securityMiddleware, this._securityMonitor);
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      // Validar headers de seguridad en la respuesta
      final headers = response.headers.map;
      if (!_securityMiddleware.validateSecurityHeaders(headers)) {
        _securityMonitor.logSecurityEvent(SecurityEvent(
          type: SecurityEventType.securityHeaderMissing,
          message: 'Respuesta sin headers de seguridad adecuados desde ${response.requestOptions.path}',
          severity: 5,
          endpoint: response.requestOptions.path,
          clientId: response.requestOptions.headers['X-Client-ID']?.toString(),
          metadata: {
            'status_code': response.statusCode,
            'missing_headers': _getMissingSecurityHeaders(headers),
          },
        ));
        
        _securityLogger.logSecurityEvent(
          level: SecurityLogLevel.warning,
          category: SecurityEventCategory.networkSecurity,
          event: 'response_security_headers_missing',
          details: {
            'endpoint': response.requestOptions.path,
            'missing_headers': _getMissingSecurityHeaders(headers),
            'status_code': response.statusCode,
          },
        );
        
        // Análisis de comportamiento para respuestas anómalas
        _behaviorAnalysis.analyzeRequest(
          endpoint: response.requestOptions.path,
          method: response.requestOptions.method,
          clientId: response.requestOptions.headers['X-Client-ID']?.toString() ?? 'unknown',
          userId: response.requestOptions.headers['X-User-ID']?.toString(),
          userAgent: response.requestOptions.headers['User-Agent']?.toString(),
          ipAddress: response.requestOptions.headers['X-Forwarded-For']?.toString(),
          headers: Map<String, dynamic>.from(response.requestOptions.headers),
          body: response.requestOptions.data is Map ? Map<String, dynamic>.from(response.requestOptions.data) : null,
        );
        
        Logger.warning('Respuesta sin headers de seguridad adecuados');
      }
      
      // Detectar posibles filtraciones de datos sensibles
      if (response.data != null) {
        final responseStr = response.data.toString();
        if (_containsSensitiveData(responseStr)) {
          _securityMonitor.logSecurityEvent(SecurityEvent(
            type: SecurityEventType.maliciousPattern,
            message: 'Posible filtración de datos sensibles detectada en respuesta',
            severity: 9,
            endpoint: response.requestOptions.path,
            clientId: response.requestOptions.headers['X-Client-ID']?.toString(),
            metadata: {
              'status_code': response.statusCode,
              'response_size': responseStr.length,
            },
          ));
          
          _securityLogger.logSecurityEvent(
            level: SecurityLogLevel.critical,
            category: SecurityEventCategory.dataAccess,
            event: 'sensitive_data_exposure',
            details: {
              'endpoint': response.requestOptions.path,
              'status_code': response.statusCode,
              'response_size': responseStr.length,
            },
          );
          
          Logger.error('Posible filtración de datos sensibles detectada');
          // En producción, podríamos censurar o bloquear la respuesta
        }
      }
      
      handler.next(response);
    } catch (e) {
      Logger.error('Error en validación de respuesta: $e');
      
      _securityMonitor.logSecurityEvent(SecurityEvent(
        type: SecurityEventType.dataValidationFailure,
        message: 'Error en validación de respuesta: $e',
        severity: 6,
        endpoint: response.requestOptions.path,
        clientId: response.requestOptions.headers['X-Client-ID']?.toString(),
        metadata: {
          'error': e.toString(),
          'status_code': response.statusCode,
        },
      ));
      
      _securityLogger.logSecurityEvent(
        level: SecurityLogLevel.warning,
        category: SecurityEventCategory.systemIntegrity,
        event: 'response_validation_error',
        details: {
          'endpoint': response.requestOptions.path,
          'error': e.toString(),
          'status_code': response.statusCode,
        },
      );
      
      handler.next(response);
    }
  }
  
  /// Detecta patrones sospechosos en el contenido
  bool _containsSensitiveData(String content) {
    final sensitivePatterns = [
      RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Tarjetas de crédito
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Emails
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
      RegExp(r'password|token|secret|key', caseSensitive: false),
    ];
    
    return sensitivePatterns.any((pattern) => pattern.hasMatch(content));
  }
  
  /// Obtiene los headers de seguridad faltantes
  List<String> _getMissingSecurityHeaders(Map<String, List<String>> headers) {
    final requiredHeaders = [
      'x-content-type-options',
      'x-frame-options',
      'x-xss-protection',
      'strict-transport-security',
    ];
    
    return requiredHeaders.where((header) => 
      !headers.keys.any((key) => key.toLowerCase() == header)
    ).toList();
  }
}
