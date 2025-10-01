import 'dart:convert';
import 'package:dio/dio.dart';
import '../utils/logger.dart';
import '../services/security_monitor_service.dart';

/// Configuración para validación de entrada
class InputValidationConfig {
  final bool enableSqlInjectionDetection;
  final bool enableXssDetection;
  final bool enableCommandInjectionDetection;
  final bool enablePathTraversalDetection;
  final int maxRequestSize;
  final int maxStringLength;
  final List<String> allowedFileExtensions;
  final List<String> blockedPatterns;
  final Map<String, ValidationRule> fieldRules;
  
  const InputValidationConfig({
    this.enableSqlInjectionDetection = true,
    this.enableXssDetection = true,
    this.enableCommandInjectionDetection = true,
    this.enablePathTraversalDetection = true,
    this.maxRequestSize = 10 * 1024 * 1024, // 10MB
    this.maxStringLength = 10000,
    this.allowedFileExtensions = const ['.jpg', '.jpeg', '.png', '.gif', '.pdf', '.txt'],
    this.blockedPatterns = const [],
    this.fieldRules = const {},
  });
}

/// Regla de validación para campos específicos
class ValidationRule {
  final String? pattern;
  final int? minLength;
  final int? maxLength;
  final bool required;
  final String? customValidator;
  
  const ValidationRule({
    this.pattern,
    this.minLength,
    this.maxLength,
    this.required = false,
    this.customValidator,
  });
}

/// Resultado de validación
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> sanitizedData;
  
  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.sanitizedData = const {},
  });
}

/// Middleware de validación de entrada
class InputValidationMiddleware extends Interceptor {
  final InputValidationConfig _config;
  final SecurityMonitorService _securityMonitor;
  
  // Patrones de detección de ataques
  static final List<RegExp> _sqlInjectionPatterns = [
    RegExp(r"('|(\-\-)|(;)|(\||\|)|(\*|\*))", caseSensitive: false),
    RegExp(r"(union|select|insert|update|delete|drop|create|alter|exec|execute)", caseSensitive: false),
    RegExp(r"(script|javascript|vbscript|onload|onerror|onclick)", caseSensitive: false),
    RegExp(r"(\<|\>|\&|\#)", caseSensitive: false),
  ];
  
  static final List<RegExp> _xssPatterns = [
    RegExp(r"<script[^>]*>.*?</script>", caseSensitive: false),
    RegExp(r"javascript:", caseSensitive: false),
    RegExp(r"on\w+\s*=", caseSensitive: false),
    RegExp(r"<iframe[^>]*>", caseSensitive: false),
    RegExp(r"<object[^>]*>", caseSensitive: false),
    RegExp(r"<embed[^>]*>", caseSensitive: false),
  ];
  
  static final List<RegExp> _commandInjectionPatterns = [
    RegExp(r"(\||&|;|\$|`|\(|\)|\{|\})", caseSensitive: false),
    RegExp(r"(cmd|powershell|bash|sh|exec|system|eval)", caseSensitive: false),
  ];
  
  static final List<RegExp> _pathTraversalPatterns = [
    RegExp(r"\.\./"),
    RegExp(r"\.\.\\"),
    RegExp(r"%2e%2e%2f", caseSensitive: false),
    RegExp(r"%2e%2e%5c", caseSensitive: false),
  ];
  
  InputValidationMiddleware({
    InputValidationConfig? config,
    SecurityMonitorService? securityMonitor,
  }) : _config = config ?? const InputValidationConfig(),
       _securityMonitor = securityMonitor ?? SecurityMonitorService();
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // Validar tamaño de la request
      if (!_validateRequestSize(options)) {
        _rejectRequest(handler, 'Request size exceeds maximum allowed');
        return;
      }
      
      // Validar headers
      final headerValidation = _validateHeaders(options.headers);
      if (!headerValidation.isValid) {
        _logSecurityViolation('header_validation', options, headerValidation.errors);
        _rejectRequest(handler, 'Invalid headers detected');
        return;
      }
      
      // Validar query parameters
      final queryValidation = _validateQueryParameters(options.queryParameters);
      if (!queryValidation.isValid) {
        _logSecurityViolation('query_validation', options, queryValidation.errors);
        _rejectRequest(handler, 'Invalid query parameters detected');
        return;
      }
      
      // Validar body data
      if (options.data != null) {
        final bodyValidation = _validateRequestBody(options.data);
        if (!bodyValidation.isValid) {
          _logSecurityViolation('body_validation', options, bodyValidation.errors);
          _rejectRequest(handler, 'Invalid request body detected');
          return;
        }
        
        // Aplicar datos sanitizados si están disponibles
        if (bodyValidation.sanitizedData.isNotEmpty) {
          options.data = bodyValidation.sanitizedData;
        }
      }
      
      // Validar path
      if (!_validatePath(options.path)) {
        _logSecurityViolation('path_validation', options, ['Path traversal detected']);
        _rejectRequest(handler, 'Invalid path detected');
        return;
      }
      
      handler.next(options);
    } catch (e) {
      Logger.error('Error in input validation middleware: $e');
      handler.next(options); // Permitir la request en caso de error
    }
  }
  
  /// Valida el tamaño de la request
  bool _validateRequestSize(RequestOptions options) {
    if (options.data == null) return true;
    
    int size = 0;
    if (options.data is String) {
      size = (options.data as String).length;
    } else if (options.data is Map) {
      size = jsonEncode(options.data).length;
    } else if (options.data is List<int>) {
      size = (options.data as List<int>).length;
    }
    
    return size <= _config.maxRequestSize;
  }
  
  /// Valida headers de la request
  ValidationResult _validateHeaders(Map<String, dynamic> headers) {
    final errors = <String>[];
    final warnings = <String>[];
    
    for (final entry in headers.entries) {
      final key = entry.key;
      final value = entry.value.toString();
      
      // Validar longitud
      if (value.length > _config.maxStringLength) {
        errors.add('Header $key exceeds maximum length');
        continue;
      }
      
      // Detectar ataques en headers
      if (_config.enableXssDetection && _containsXss(value)) {
        errors.add('XSS detected in header $key');
      }
      
      if (_config.enableSqlInjectionDetection && _containsSqlInjection(value)) {
        errors.add('SQL injection detected in header $key');
      }
      
      if (_config.enableCommandInjectionDetection && _containsCommandInjection(value)) {
        errors.add('Command injection detected in header $key');
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Valida query parameters
  ValidationResult _validateQueryParameters(Map<String, dynamic> queryParams) {
    final errors = <String>[];
    final warnings = <String>[];
    
    for (final entry in queryParams.entries) {
      final key = entry.key;
      final value = entry.value.toString();
      
      // Validar longitud
      if (value.length > _config.maxStringLength) {
        errors.add('Query parameter $key exceeds maximum length');
        continue;
      }
      
      // Detectar ataques
      if (_config.enableXssDetection && _containsXss(value)) {
        errors.add('XSS detected in query parameter $key');
      }
      
      if (_config.enableSqlInjectionDetection && _containsSqlInjection(value)) {
        errors.add('SQL injection detected in query parameter $key');
      }
      
      if (_config.enableCommandInjectionDetection && _containsCommandInjection(value)) {
        errors.add('Command injection detected in query parameter $key');
      }
      
      if (_config.enablePathTraversalDetection && _containsPathTraversal(value)) {
        errors.add('Path traversal detected in query parameter $key');
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Valida el body de la request
  ValidationResult _validateRequestBody(dynamic data) {
    final errors = <String>[];
    final warnings = <String>[];
    final sanitizedData = <String, dynamic>{};
    
    if (data is Map<String, dynamic>) {
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;
        
        final fieldValidation = _validateField(key, value);
        if (!fieldValidation.isValid) {
          errors.addAll(fieldValidation.errors);
        }
        warnings.addAll(fieldValidation.warnings);
        
        // Aplicar datos sanitizados
        if (fieldValidation.sanitizedData.isNotEmpty) {
          sanitizedData[key] = fieldValidation.sanitizedData[key];
        } else {
          sanitizedData[key] = value;
        }
      }
    } else if (data is String) {
      final fieldValidation = _validateField('body', data);
      if (!fieldValidation.isValid) {
        errors.addAll(fieldValidation.errors);
      }
      warnings.addAll(fieldValidation.warnings);
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      sanitizedData: sanitizedData,
    );
  }
  
  /// Valida un campo específico
  ValidationResult _validateField(String fieldName, dynamic value) {
    final errors = <String>[];
    final warnings = <String>[];
    final sanitizedData = <String, dynamic>{};
    
    if (value == null) {
      final rule = _config.fieldRules[fieldName];
      if (rule?.required == true) {
        errors.add('Field $fieldName is required');
      }
      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    }
    
    final stringValue = value.toString();
    
    // Validar longitud
    if (stringValue.length > _config.maxStringLength) {
      errors.add('Field $fieldName exceeds maximum length');
      return ValidationResult(
        isValid: false,
        errors: errors,
        warnings: warnings,
      );
    }
    
    // Aplicar reglas específicas del campo
    final rule = _config.fieldRules[fieldName];
    if (rule != null) {
      if (rule.minLength != null && stringValue.length < rule.minLength!) {
        errors.add('Field $fieldName is too short');
      }
      
      if (rule.maxLength != null && stringValue.length > rule.maxLength!) {
        errors.add('Field $fieldName is too long');
      }
      
      if (rule.pattern != null && !RegExp(rule.pattern!).hasMatch(stringValue)) {
        errors.add('Field $fieldName does not match required pattern');
      }
    }
    
    // Detectar ataques
    if (_config.enableXssDetection && _containsXss(stringValue)) {
      errors.add('XSS detected in field $fieldName');
    }
    
    if (_config.enableSqlInjectionDetection && _containsSqlInjection(stringValue)) {
      errors.add('SQL injection detected in field $fieldName');
    }
    
    if (_config.enableCommandInjectionDetection && _containsCommandInjection(stringValue)) {
      errors.add('Command injection detected in field $fieldName');
    }
    
    if (_config.enablePathTraversalDetection && _containsPathTraversal(stringValue)) {
      errors.add('Path traversal detected in field $fieldName');
    }
    
    // Sanitizar datos si es necesario
    String sanitizedValue = _sanitizeString(stringValue);
    if (sanitizedValue != stringValue) {
      sanitizedData[fieldName] = sanitizedValue;
      warnings.add('Field $fieldName was sanitized');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      sanitizedData: sanitizedData,
    );
  }
  
  /// Valida el path de la request
  bool _validatePath(String path) {
    if (_config.enablePathTraversalDetection && _containsPathTraversal(path)) {
      return false;
    }
    
    // Validar caracteres peligrosos en el path
    if (path.contains('..') || path.contains('~') || path.contains('\\')) {
      return false;
    }
    
    return true;
  }
  
  /// Detecta SQL injection
  bool _containsSqlInjection(String input) {
    return _sqlInjectionPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  /// Detecta XSS
  bool _containsXss(String input) {
    return _xssPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  /// Detecta command injection
  bool _containsCommandInjection(String input) {
    return _commandInjectionPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  /// Detecta path traversal
  bool _containsPathTraversal(String input) {
    return _pathTraversalPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  /// Sanitiza una cadena de texto
  String _sanitizeString(String input) {
    String sanitized = input;
    
    // Escapar caracteres HTML
    sanitized = sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
    
    // Remover caracteres de control
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    
    return sanitized;
  }
  
  /// Registra una violación de seguridad
  void _logSecurityViolation(
    String type,
    RequestOptions options,
    List<String> errors,
  ) {
    final clientId = _getClientId(options);
    
    Logger.warning(
      'Input validation violation - Type: $type, Client: $clientId, '
      'Path: ${options.path}, Errors: ${errors.join(", ")}'
    );
    
    _securityMonitor.logSecurityEvent(SecurityEvent(
      type: SecurityEventType.invalidInput,
      message: 'Input validation failed: $type',
      severity: 5,
      endpoint: options.path,
      clientId: clientId,
      metadata: {
        'method': options.method,
        'errors': errors,
        'user_agent': options.headers['User-Agent'],
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }
  
  /// Obtiene el ID del cliente
  String _getClientId(RequestOptions options) {
    final ip = options.headers['X-Forwarded-For'] ?? 
              options.headers['X-Real-IP'] ?? 
              'unknown';
    final userAgent = options.headers['User-Agent'] ?? 'unknown';
    return '$ip:${userAgent.hashCode}';
  }
  
  /// Rechaza una request
  void _rejectRequest(RequestInterceptorHandler handler, String message) {
    handler.reject(
      DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          statusMessage: 'Bad Request',
          data: {'error': message},
        ),
        type: DioExceptionType.badResponse,
        message: message,
      ),
    );
  }
  
  /// Obtiene estadísticas de validación
  Map<String, dynamic> getStats() {
    return {
      'config': {
        'sql_injection_detection': _config.enableSqlInjectionDetection,
        'xss_detection': _config.enableXssDetection,
        'command_injection_detection': _config.enableCommandInjectionDetection,
        'path_traversal_detection': _config.enablePathTraversalDetection,
        'max_request_size': _config.maxRequestSize,
        'max_string_length': _config.maxStringLength,
      },
      'patterns': {
        'sql_injection_patterns': _sqlInjectionPatterns.length,
        'xss_patterns': _xssPatterns.length,
        'command_injection_patterns': _commandInjectionPatterns.length,
        'path_traversal_patterns': _pathTraversalPatterns.length,
      },
    };
  }
}
