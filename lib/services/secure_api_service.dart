import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/pepito_activity.dart';
import '../config/environment.dart';
import '../utils/logger.dart';
import '../middleware/security_middleware.dart';
import '../middleware/rate_limit_middleware.dart';
import '../middleware/cache_middleware.dart';
import 'auth_service.dart';
import 'security_monitor_service.dart';
import 'cache_service.dart';

class SecureApiService {
  static final SecureApiService _instance = SecureApiService._internal();
  factory SecureApiService() => _instance;
  SecureApiService._internal() {
    _cacheService = CacheService.instance;
    initialize();
  }

  late final Dio _dio;
  final AuthService _authService = AuthService();
  final RateLimitMiddleware _rateLimitMiddleware = RateLimitMiddleware();
  final SecurityMiddleware _securityMiddleware = SecurityMiddleware();
  final SecurityMonitorService _securityMonitor = SecurityMonitorService();
  late final CacheService _cacheService;
  
  bool _isInitialized = false;
  
  // Rate limiting
  final Map<String, List<DateTime>> _requestHistory = {};
  static const int _maxRequestsPerMinute = 60;
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  
  /// Inicializa el servicio de API seguro
  void initialize() {
    if (_isInitialized) return;
    
    // Inicializar cache service
    _cacheService.initialize();
    
    _dio = Dio(BaseOptions(
      baseUrl: Environment.supabaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (!kIsWeb) 'User-Agent': 'PepitoApp/${Environment.appVersion}',
        'X-Client-Platform': kIsWeb ? 'web' : Platform.operatingSystem,
        'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
        'apikey': Environment.supabaseAnonKey,
      },
    ));
    
    // Agregar interceptores de seguridad mejorados
    _dio.interceptors.addAll([
      DistributedCacheInterceptor(_cacheService), // Cache distribuido
      CacheWarmupInterceptor(_cacheService), // Precarga de cache
      CacheOptimizationInterceptor(_cacheService), // Optimización automática
      InputValidationInterceptor(), // Validación de entrada
      _AuthInterceptor(_authService, _securityMonitor),
      RateLimitInterceptor(_rateLimitMiddleware, _securityMonitor), // Rate limiting avanzado
      _SecurityInterceptor(_securityMonitor),
      ResponseValidationInterceptor(_securityMiddleware, _securityMonitor), // Validación de respuesta
      _LoggingInterceptor(),
    ]);
    
    _isInitialized = true;
  }
  
  /// Obtiene el estado actual de Pépito a través de Edge Function
  Future<PepitoActivity?> getCurrentStatus() async {
    try {
      Logger.info('[SecureAPI] Obteniendo estado a través de Edge Function');
      
      if (!_checkRateLimit('getCurrentStatus')) {
        throw DioException(
          requestOptions: RequestOptions(path: '/functions/v1/pepito-proxy/status'),
          error: 'Rate limit exceeded',
          type: DioExceptionType.unknown,
        );
      }
      
      final response = await _dio.get(
        '/functions/v1/pepito-proxy/status',
        options: Options(
          headers: await _getSecurityHeaders(),
          extra: {
            'cache_ttl': const Duration(seconds: 30),
            'retry_attempts': 3,
          },
        ).copyWith(
          extra: {
            ...Options().extra ?? {},
            'dio_cache_interceptor_options': _cacheService.getCacheOptionsForEndpoint('/status'),
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        Logger.info('[SecureAPI] Estado obtenido exitosamente');
        
        // Crear actividad desde la respuesta de la Edge Function
        final activity = PepitoActivity(
          id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          event: data['event'] ?? 'unknown',
          type: data['type'] ?? 'unknown',
          timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
          imageUrl: data['imageUrl'] ?? data['img'],
          source: data['source'] ?? 'edge_function',
          cached: data['cached'] ?? false,
          authenticated: data['authenticated'] ?? false,
        );
        
        Logger.info('Estado obtenido exitosamente: ${activity.event}');
        return activity;
      }
      
      return null;
    } catch (e) {
      Logger.error('[SecureAPI] Error obteniendo estado: $e');
      return null;
    }
  }
  
  /// Verifica el estado de salud de la Edge Function
  Future<Map<String, dynamic>?> getHealthStatus() async {
    try {
      final response = await _dio.get(
        '/functions/v1/pepito-proxy/health',
        options: Options(
          extra: {
            'cache_ttl': const Duration(seconds: 10),
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      Logger.error('Error verificando salud del servicio', e);
      return null;
    }
  }
  
  /// Limpia el cache del servicio
  Future<void> clearCache() async {
    try {
      await _cacheService.clearAllCache();
      Logger.info('Cache limpiado exitosamente');
    } catch (e) {
      Logger.error('Error limpiando cache', e);
    }
  }
  
  /// Limpia cache por tipo específico
  Future<void> clearCacheByType(CacheType type) async {
    try {
      await _cacheService.clearCacheByType(type);
      Logger.info('Cache de tipo $type limpiado exitosamente');
    } catch (e) {
      Logger.error('Error limpiando cache de tipo $type', e);
    }
  }
  
  /// Optimiza el cache eliminando entradas expiradas
  Future<void> optimizeCache() async {
    try {
      await _cacheService.optimizeCache();
      Logger.info('Cache optimizado exitosamente');
    } catch (e) {
      Logger.error('Error optimizando cache', e);
    }
  }
  
  /// Precarga cache para endpoints críticos
  Future<void> warmupCache() async {
    try {
      final criticalEndpoints = [
        '/functions/v1/pepito-proxy/status',
        '/functions/v1/pepito-proxy/analytics',
      ];
      
      await _cacheService.warmupCache(criticalEndpoints);
      Logger.info('Cache warmup completado');
    } catch (e) {
      Logger.error('Error en cache warmup', e);
    }
  }
  
  /// Verifica el rate limiting para un endpoint específico
  bool _checkRateLimit(String endpoint) {
    final now = DateTime.now();
    final key = '${endpoint}_${_authService.currentUser?.id ?? 'anonymous'}';
    
    // Limpiar requests antiguos
    _requestHistory[key]?.removeWhere(
      (timestamp) => now.difference(timestamp) > _rateLimitWindow,
    );
    
    final requests = _requestHistory[key] ?? [];
    
    if (requests.length >= _maxRequestsPerMinute) {
      Logger.warning('Rate limit excedido para $endpoint');
      return false;
    }
    
    requests.add(now);
    _requestHistory[key] = requests;
    
    return true;
  }
  
  /// Obtiene las actividades de Pépito a través de Edge Function
  Future<List<PepitoActivity>> getActivities({int limit = 10}) async {
    try {
      Logger.info('[SecureAPI] Obteniendo actividades a través de Edge Function');
      
      if (!_checkRateLimit('getActivities')) {
        throw DioException(
          requestOptions: RequestOptions(path: '/functions/v1/pepito-proxy/activities'),
          error: 'Rate limit exceeded',
          type: DioExceptionType.unknown,
        );
      }
      
      final response = await _dio.get(
        '/functions/v1/pepito-proxy/activities',
        queryParameters: {'limit': limit},
        options: Options(
          headers: await _getSecurityHeaders(),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> activitiesData = response.data;
        Logger.info('[SecureAPI] ${activitiesData.length} actividades obtenidas');
        
        return activitiesData.map((data) => PepitoActivity(
          id: data['id'] ?? 'activity_${DateTime.now().millisecondsSinceEpoch}',
          event: data['event'] ?? 'Desconocido',
          type: data['type'] ?? 'unknown',
          timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
          imageUrl: data['img'] ?? '',
          source: 'edge_function',
          cached: data['cached'] ?? false,
          authenticated: true,
        )).toList();
      }
      
      return [];
    } catch (e) {
      Logger.error('[SecureAPI] Error obteniendo actividades: $e');
      return [];
    }
  }
  
  /// Genera headers de seguridad para las peticiones
  Future<Map<String, String>> _getSecurityHeaders() async {
    final headers = <String, String>{
      'X-Client-Platform': kIsWeb ? 'web' : Platform.operatingSystem,
      'X-App-Version': Environment.appVersion,
      'X-Request-ID': DateTime.now().millisecondsSinceEpoch.toString(),
      // Añadir autenticación de Supabase
      'Authorization': 'Bearer ${Environment.supabaseAnonKey}',
      'apikey': Environment.supabaseAnonKey,
    };
    
    // Añadir información del usuario si está autenticado
    final user = _authService.currentUser;
    if (user != null) {
      headers['X-User-ID'] = user.id;
      
      // Generar session ID basado en el usuario y timestamp
      final sessionData = '${user.id}_${DateTime.now().day}';
      headers['X-Session-ID'] = sessionData.hashCode.abs().toString();
    }
    
    return headers;
  }
  
  /// Obtiene estadísticas del cache
  Future<Map<String, dynamic>> getCacheStats() async {
    final cacheStats = await _cacheService.getCacheStats();
    return {
      'cache_stats': cacheStats.toMap(),
      'rate_limit_entries': _requestHistory.length,
      'authenticated': _authService.isAuthenticated,
      'user_id': _authService.currentUser?.id,
    };
  }
  
  /// Limpia el historial de rate limiting
  void clearRateLimitHistory() {
    _requestHistory.clear();
    Logger.info('Historial de rate limiting limpiado');
  }
}

/// Interceptor para manejar autenticación automática
class _AuthInterceptor extends Interceptor {
  final AuthService _authService;
  final SecurityMonitorService _securityMonitor;
  
  _AuthInterceptor(this._authService, this._securityMonitor);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _authService.getCurrentToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      Logger.warning('No se pudo obtener token de autenticación: $e');
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Registrar fallo de autenticación
      _securityMonitor.logSecurityEvent(SecurityEvent(
        type: SecurityEventType.authenticationFailure,
        message: 'Token expirado o inválido para ${err.requestOptions.path}',
        severity: 6,
        endpoint: err.requestOptions.path,
        clientId: err.requestOptions.headers['X-Client-ID']?.toString(),
        metadata: {
          'status_code': err.response?.statusCode,
          'method': err.requestOptions.method,
        },
      ));
      
      try {
        // Intentar renovar token y reintentar
        final newToken = await _authService.getCurrentToken();
        if (newToken != null) {
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';
          
          final dio = Dio();
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        Logger.error('Error renovando token', e);
        _securityMonitor.logSecurityEvent(SecurityEvent(
          type: SecurityEventType.authenticationFailure,
          message: 'Error renovando token: $e',
          severity: 8,
          endpoint: err.requestOptions.path,
          clientId: err.requestOptions.headers['X-Client-ID']?.toString(),
        ));
      }
    }
    
    handler.next(err);
  }
}

// Interceptor _RateLimitInterceptor removido - ahora se usa RateLimitInterceptor del middleware

/// Interceptor para seguridad adicional
class _SecurityInterceptor extends Interceptor {
  final SecurityMonitorService _securityMonitor;
  
  _SecurityInterceptor(this._securityMonitor);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Agregar headers de seguridad adicionales
    options.headers['X-Requested-With'] = 'PepitoApp';
    options.headers['X-Client-Type'] = 'mobile';
    options.headers['X-API-Version'] = '1.0';
    
    // Validar que no se envíen datos sensibles en logs
    if (options.data is Map) {
      final data = Map<String, dynamic>.from(options.data);
      data.removeWhere((key, value) => 
        key.toLowerCase().contains('password') ||
        key.toLowerCase().contains('token') ||
        key.toLowerCase().contains('secret') ||
        key.toLowerCase().contains('key')
      );
    }
    
    // Validar que la URL sea segura (HTTPS para producción)
    if (!kDebugMode && !options.uri.isScheme('https')) {
      _securityMonitor.logSecurityEvent(SecurityEvent(
        type: SecurityEventType.httpsViolation,
        message: 'Intento de conexión no HTTPS en producción: ${options.uri}',
        severity: 9,
        endpoint: options.path,
        clientId: options.headers['X-Client-ID']?.toString(),
        metadata: {
          'uri': options.uri.toString(),
          'method': options.method,
        },
      ));
      
      throw DioException(
        requestOptions: options,
        error: 'HTTPS required in production',
        type: DioExceptionType.badResponse,
      );
    }
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Validar headers de seguridad en la respuesta
    final securityHeaders = response.headers.map;
    if (!securityHeaders.containsKey('x-request-id')) {
      Logger.warning('Respuesta sin X-Request-ID header');
    }
    
    handler.next(response);
  }
}

/// Interceptor para logging seguro
class _LoggingInterceptor extends Interceptor {
  _LoggingInterceptor();
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.info('API Request: ${options.method} ${options.path}');
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.info('API Response: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.error('API Error: ${err.message}', err);
    handler.next(err);
  }
}
