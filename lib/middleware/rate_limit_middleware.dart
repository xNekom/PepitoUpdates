import 'dart:collection';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import '../services/auth_service.dart';
import '../services/security_monitor_service.dart';
import '../services/security_logging_service.dart';

/// Configuración de rate limiting por endpoint
class RateLimitConfig {
  final int maxRequests;
  final Duration window;
  final Duration blockDuration;
  final bool enabled;
  
  const RateLimitConfig({
    required this.maxRequests,
    required this.window,
    this.blockDuration = const Duration(minutes: 5),
    this.enabled = true,
  });
}

/// Información de rate limiting para un cliente
class RateLimitInfo {
  final Queue<DateTime> requests;
  DateTime? blockedUntil;
  int violationCount;
  
  RateLimitInfo() : requests = Queue<DateTime>(), violationCount = 0;
  
  bool get isBlocked => blockedUntil != null && DateTime.now().isBefore(blockedUntil!);
  
  void addRequest() {
    requests.add(DateTime.now());
  }
  
  void cleanOldRequests(Duration window) {
    final cutoff = DateTime.now().subtract(window);
    while (requests.isNotEmpty && requests.first.isBefore(cutoff)) {
      requests.removeFirst();
    }
  }
  
  void block(Duration duration) {
    blockedUntil = DateTime.now().add(duration);
    violationCount++;
    Logger.warning('Cliente bloqueado por rate limiting. Violaciones: $violationCount');
  }
  
  void reset() {
    requests.clear();
    blockedUntil = null;
  }
}

/// Middleware avanzado de rate limiting
class RateLimitMiddleware {
  static final RateLimitMiddleware _instance = RateLimitMiddleware._internal();
  factory RateLimitMiddleware() => _instance;
  RateLimitMiddleware._internal();
  
  final Map<String, RateLimitInfo> _clientLimits = {};
  final AuthService _authService = AuthService();
  
  // Configuraciones por endpoint
  static const Map<String, RateLimitConfig> _endpointConfigs = {
    'default': RateLimitConfig(
      maxRequests: 60,
      window: Duration(minutes: 1),
    ),
    'auth': RateLimitConfig(
      maxRequests: 5,
      window: Duration(minutes: 1),
      blockDuration: Duration(minutes: 15),
    ),
    'status': RateLimitConfig(
      maxRequests: 30,
      window: Duration(minutes: 1),
    ),
    'activities': RateLimitConfig(
      maxRequests: 20,
      window: Duration(minutes: 1),
    ),
    'critical': RateLimitConfig(
      maxRequests: 3,
      window: Duration(minutes: 5),
      blockDuration: Duration(minutes: 30),
    ),
  };
  
  /// Verifica si una petición está permitida
  bool isRequestAllowed(String endpoint, {String? clientId}) {
    final config = _getConfigForEndpoint(endpoint);
    if (!config.enabled) return true;
    
    final client = _getClientId(clientId);
    final limitInfo = _clientLimits.putIfAbsent(client, () => RateLimitInfo());
    
    // Verificar si está bloqueado
    if (limitInfo.isBlocked) {
      Logger.warning('Petición bloqueada para cliente $client en endpoint $endpoint');
      return false;
    }
    
    // Limpiar peticiones antiguas
    limitInfo.cleanOldRequests(config.window);
    
    // Verificar límite
    if (limitInfo.requests.length >= config.maxRequests) {
      limitInfo.block(config.blockDuration);
      _logRateLimitViolation(client, endpoint, config);
      return false;
    }
    
    // Registrar petición
    limitInfo.addRequest();
    return true;
  }
  
  /// Obtiene la configuración para un endpoint
  RateLimitConfig _getConfigForEndpoint(String endpoint) {
    // Buscar configuración específica
    for (final entry in _endpointConfigs.entries) {
      if (endpoint.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Configuración por defecto
    return _endpointConfigs['default']!;
  }
  
  /// Obtiene el ID del cliente
  String _getClientId(String? providedId) {
    if (providedId != null) return providedId;
    
    // Usar ID de usuario si está autenticado
    final user = _authService.currentUser;
    if (user != null) {
      return 'user_${user.id}';
    }
    
    // Usar identificador de dispositivo
    return 'device_${kIsWeb ? 'web' : Platform.operatingSystem}_${DateTime.now().day}';
  }
  
  /// Registra una violación de rate limiting
  void _logRateLimitViolation(String client, String endpoint, RateLimitConfig config) {
    Logger.warning(
      'Rate limit violado - Cliente: $client, Endpoint: $endpoint, '
      'Límite: ${config.maxRequests}/${config.window.inMinutes}min'
    );
    
    // En producción, podríamos enviar esto a un sistema de monitoreo
    _reportSecurityEvent({
      'event': 'rate_limit_violation',
      'client': client,
      'endpoint': endpoint,
      'limit': config.maxRequests,
      'window_minutes': config.window.inMinutes,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Reporta eventos de seguridad
  void _reportSecurityEvent(Map<String, dynamic> event) {
    // Aquí se podría integrar con un sistema de monitoreo
    Logger.info('Evento de seguridad: ${event['event']}');
  }
  
  /// Obtiene estadísticas de rate limiting
  Map<String, dynamic> getStats() {
    final stats = <String, dynamic>{
      'total_clients': _clientLimits.length,
      'blocked_clients': 0,
      'total_violations': 0,
      'clients': <String, dynamic>{},
    };
    
    for (final entry in _clientLimits.entries) {
      final client = entry.key;
      final info = entry.value;
      
      if (info.isBlocked) {
        stats['blocked_clients']++;
      }
      
      stats['total_violations'] += info.violationCount;
      
      stats['clients'][client] = {
        'requests_in_window': info.requests.length,
        'is_blocked': info.isBlocked,
        'violations': info.violationCount,
        'blocked_until': info.blockedUntil?.toIso8601String(),
      };
    }
    
    return stats;
  }
  
  /// Limpia datos antiguos
  void cleanup() {
    final now = DateTime.now();
    
    _clientLimits.removeWhere((client, info) {
      // Remover clientes sin actividad reciente
      if (info.requests.isEmpty && 
          (info.blockedUntil == null || now.isAfter(info.blockedUntil!))) {
        return true;
      }
      
      // Limpiar peticiones muy antiguas
      info.cleanOldRequests(const Duration(hours: 24));
      
      return false;
    });
    
    Logger.info('Limpieza de rate limiting completada. Clientes activos: ${_clientLimits.length}');
  }
  
  /// Resetea los límites para un cliente
  void resetClient(String clientId) {
    final info = _clientLimits[clientId];
    if (info != null) {
      info.reset();
      Logger.info('Rate limiting reseteado para cliente: $clientId');
    }
  }
  
  /// Resetea todos los límites
  void resetAll() {
    _clientLimits.clear();
    Logger.info('Todos los rate limits han sido reseteados');
  }
  
  /// Bloquea manualmente un cliente
  void blockClient(String clientId, Duration duration) {
    final info = _clientLimits.putIfAbsent(clientId, () => RateLimitInfo());
    info.block(duration);
    Logger.warning('Cliente $clientId bloqueado manualmente por ${duration.inMinutes} minutos');
  }
  
  /// Desbloquea un cliente
  void unblockClient(String clientId) {
    final info = _clientLimits[clientId];
    if (info != null) {
      info.blockedUntil = null;
      Logger.info('Cliente $clientId desbloqueado manualmente');
    }
  }
}

/// Interceptor de Dio para rate limiting
class RateLimitInterceptor extends Interceptor {
  final RateLimitMiddleware _rateLimitMiddleware;
  final SecurityMonitorService _securityMonitor;
  final SecurityLoggingService _securityLogger = SecurityLoggingService.instance;
  
  RateLimitInterceptor(this._rateLimitMiddleware, this._securityMonitor);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final endpoint = _extractEndpoint(options.path);
      final clientId = _extractClientId(options.headers);
      
      if (!_rateLimitMiddleware.isRequestAllowed(endpoint, clientId: clientId)) {
        // Registrar violación de rate limit
        _securityMonitor.logSecurityEvent(SecurityEvent(
          type: SecurityEventType.rateLimitViolation,
          message: 'Rate limit excedido para endpoint $endpoint por cliente $clientId',
          severity: 6,
          endpoint: endpoint,
          clientId: clientId,
          metadata: {
            'method': options.method,
            'path': options.path,
            'user_agent': options.headers['user-agent']?.toString(),
          },
        ));
        
        // Registrar en el servicio de logging de seguridad
        _securityLogger.logRateLimitViolation(
          'rate_limit_exceeded',
          {
            'endpoint': endpoint,
            'client_id': clientId,
            'method': options.method,
            'path': options.path,
            'user_agent': options.headers['user-agent']?.toString(),
          },
          ipAddress: _extractIpAddress(options),
        );
        
        // Agregar headers informativos
        final config = RateLimitMiddleware._endpointConfigs[endpoint] ?? 
                      RateLimitMiddleware._endpointConfigs['default']!;
        
        throw DioException(
          requestOptions: options,
          error: 'Rate limit exceeded',
          type: DioExceptionType.unknown,
          response: Response(
            requestOptions: options,
            statusCode: 429,
            statusMessage: 'Too Many Requests',
            headers: Headers.fromMap({
              'retry-after': [config.blockDuration.inSeconds.toString()],
              'x-ratelimit-limit': [config.maxRequests.toString()],
              'x-ratelimit-window': [config.window.inSeconds.toString()],
            }),
          ),
        );
      }
      
      // Agregar headers de rate limiting
      options.headers['X-RateLimit-Client'] = clientId ?? 'anonymous';
      options.headers['X-RateLimit-Endpoint'] = endpoint;
      
      handler.next(options);
    } catch (e) {
      if (e is DioException) {
        handler.reject(e);
      } else {
        Logger.error('Error en rate limiting', e);
        handler.next(options); // Continuar en caso de error interno
      }
    }
  }
  
  String _extractEndpoint(String path) {
    // Extraer el tipo de endpoint de la ruta
    if (path.contains('auth') || path.contains('login') || path.contains('register')) {
      return 'auth';
    } else if (path.contains('status')) {
      return 'status';
    } else if (path.contains('activities')) {
      return 'activities';
    } else if (path.contains('admin') || path.contains('delete') || path.contains('critical')) {
      return 'critical';
    }
    
    return 'default';
  }
  
  String? _extractClientId(Map<String, dynamic> headers) {
    // Buscar ID de cliente en headers
    return headers['x-client-id'] ?? 
           headers['x-user-id'] ?? 
           headers['x-session-id'];
  }
  
  String? _extractIpAddress(RequestOptions options) {
    // Extraer dirección IP de los headers
    return options.headers['x-forwarded-for'] ?? 
           options.headers['x-real-ip'] ?? 
           options.headers['remote-addr'];
  }
}
