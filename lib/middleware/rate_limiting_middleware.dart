import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import '../utils/logger.dart';
import '../services/security_monitor_service.dart';

/// Configuración para rate limiting
class RateLimitConfig {
  final int maxRequests;
  final Duration window;
  final Duration blockDuration;
  final List<String> exemptPaths;
  final Map<String, int> pathSpecificLimits;
  
  const RateLimitConfig({
    this.maxRequests = 100,
    this.window = const Duration(minutes: 1),
    this.blockDuration = const Duration(minutes: 5),
    this.exemptPaths = const [],
    this.pathSpecificLimits = const {},
  });
}

/// Información de rate limiting por cliente
class ClientRateInfo {
  final Queue<DateTime> requests;
  DateTime? blockedUntil;
  int violationCount;
  
  ClientRateInfo() : 
    requests = Queue<DateTime>(),
    violationCount = 0;
  
  bool get isBlocked => 
    blockedUntil != null && DateTime.now().isBefore(blockedUntil!);
  
  void addRequest() {
    requests.add(DateTime.now());
  }
  
  void cleanOldRequests(Duration window) {
    final cutoff = DateTime.now().subtract(window);
    while (requests.isNotEmpty && requests.first.isBefore(cutoff)) {
      requests.removeFirst();
    }
  }
  
  int getRequestCount() => requests.length;
  
  void block(Duration duration) {
    blockedUntil = DateTime.now().add(duration);
    violationCount++;
  }
  
  void reset() {
    requests.clear();
    blockedUntil = null;
  }
}

/// Middleware de rate limiting
class RateLimitingMiddleware extends Interceptor {
  final RateLimitConfig _config;
  final SecurityMonitorService _securityMonitor;
  final Map<String, ClientRateInfo> _clients = {};
  Timer? _cleanupTimer;
  
  RateLimitingMiddleware({
    RateLimitConfig? config,
    SecurityMonitorService? securityMonitor,
  }) : _config = config ?? const RateLimitConfig(),
       _securityMonitor = securityMonitor ?? SecurityMonitorService() {
    _startCleanupTimer();
  }
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final clientId = _getClientId(options);
      final path = options.path;
      
      // Verificar si la ruta está exenta
      if (_isExemptPath(path)) {
        handler.next(options);
        return;
      }
      
      final clientInfo = _getOrCreateClientInfo(clientId);
      
      // Verificar si el cliente está bloqueado
      if (clientInfo.isBlocked) {
        _logRateLimitViolation(clientId, path, 'Client blocked');
        _rejectRequest(handler, 'Rate limit exceeded. Try again later.');
        return;
      }
      
      // Limpiar requests antiguos
      clientInfo.cleanOldRequests(_config.window);
      
      // Obtener límite específico para la ruta o usar el general
      final limit = _getPathLimit(path);
      
      // Verificar límite de requests
      if (clientInfo.getRequestCount() >= limit) {
        clientInfo.block(_config.blockDuration);
        _logRateLimitViolation(clientId, path, 'Rate limit exceeded');
        _rejectRequest(handler, 'Rate limit exceeded. Try again later.');
        return;
      }
      
      // Registrar la request
      clientInfo.addRequest();
      
      // Agregar headers informativos
      options.headers['X-RateLimit-Limit'] = limit.toString();
      options.headers['X-RateLimit-Remaining'] = 
          (limit - clientInfo.getRequestCount()).toString();
      options.headers['X-RateLimit-Reset'] = 
          DateTime.now().add(_config.window).millisecondsSinceEpoch.toString();
      
      handler.next(options);
    } catch (e) {
      Logger.error('Error in rate limiting middleware: $e');
      handler.next(options); // Permitir la request en caso de error
    }
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Agregar headers de rate limit a la respuesta
    final clientId = _getClientId(response.requestOptions);
    final clientInfo = _clients[clientId];
    
    if (clientInfo != null) {
      final limit = _getPathLimit(response.requestOptions.path);
      response.headers.add('X-RateLimit-Limit', limit.toString());
      response.headers.add('X-RateLimit-Remaining', 
          (limit - clientInfo.getRequestCount()).toString());
      response.headers.add('X-RateLimit-Reset', 
          DateTime.now().add(_config.window).millisecondsSinceEpoch.toString());
    }
    
    handler.next(response);
  }
  
  /// Obtiene el ID del cliente basado en IP y User-Agent
  String _getClientId(RequestOptions options) {
    final ip = options.headers['X-Forwarded-For'] ?? 
              options.headers['X-Real-IP'] ?? 
              'unknown';
    final userAgent = options.headers['User-Agent'] ?? 'unknown';
    return '$ip:${userAgent.hashCode}';
  }
  
  /// Verifica si una ruta está exenta de rate limiting
  bool _isExemptPath(String path) {
    return _config.exemptPaths.any((exemptPath) => 
        path.startsWith(exemptPath));
  }
  
  /// Obtiene o crea información del cliente
  ClientRateInfo _getOrCreateClientInfo(String clientId) {
    return _clients.putIfAbsent(clientId, () => ClientRateInfo());
  }
  
  /// Obtiene el límite específico para una ruta
  int _getPathLimit(String path) {
    for (final entry in _config.pathSpecificLimits.entries) {
      if (path.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return _config.maxRequests;
  }
  
  /// Rechaza una request por rate limiting
  void _rejectRequest(RequestInterceptorHandler handler, String message) {
    handler.reject(
      DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 429,
          statusMessage: 'Too Many Requests',
          data: {'error': message},
        ),
        type: DioExceptionType.badResponse,
        message: message,
      ),
    );
  }
  
  /// Registra una violación de rate limit
  void _logRateLimitViolation(String clientId, String path, String reason) {
    Logger.warning(
      'Rate limit violation - Client: $clientId, Path: $path, Reason: $reason'
    );
    
    // Registrar evento de seguridad
    _securityMonitor.logSecurityEvent(SecurityEvent(
      type: SecurityEventType.rateLimitViolation,
      message: 'Rate limit exceeded for path $path',
      severity: 4,
      endpoint: path,
      clientId: clientId,
      metadata: {
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }
  
  /// Inicia el timer de limpieza
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _cleanupOldClients(),
    );
  }
  
  /// Limpia clientes antiguos e inactivos
  void _cleanupOldClients() {
    final now = DateTime.now();
    
    _clients.removeWhere((clientId, clientInfo) {
      clientInfo.cleanOldRequests(_config.window);
      
      // Remover clientes sin requests recientes y no bloqueados
      return clientInfo.getRequestCount() == 0 && 
             (clientInfo.blockedUntil == null || 
              now.isAfter(clientInfo.blockedUntil!));
    });
    
    Logger.info('Rate limiting cleanup completed. Active clients: ${_clients.length}');
  }
  
  /// Obtiene estadísticas de rate limiting
  Map<String, dynamic> getStats() {
    int blockedClients = 0;
    int totalRequests = 0;
    
    for (final clientInfo in _clients.values) {
      if (clientInfo.isBlocked) blockedClients++;
      totalRequests += clientInfo.getRequestCount();
    }
    
    return {
      'total_clients': _clients.length,
      'blocked_clients': blockedClients,
      'total_requests': totalRequests,
      'config': {
        'max_requests': _config.maxRequests,
        'window_minutes': _config.window.inMinutes,
        'block_duration_minutes': _config.blockDuration.inMinutes,
      },
    };
  }
  
  /// Desbloquea un cliente específico
  void unblockClient(String clientId) {
    final clientInfo = _clients[clientId];
    if (clientInfo != null) {
      clientInfo.reset();
      Logger.info('Client unblocked: $clientId');
    }
  }
  
  /// Desbloquea todos los clientes
  void unblockAllClients() {
    for (final clientInfo in _clients.values) {
      clientInfo.reset();
    }
    Logger.info('All clients unblocked');
  }
  
  /// Limpia recursos al destruir el middleware
  void dispose() {
    _cleanupTimer?.cancel();
    _clients.clear();
  }
}
