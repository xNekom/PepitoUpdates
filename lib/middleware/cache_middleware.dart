import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import '../services/cache_service.dart';
import '../utils/logger.dart';

/// Interceptor de cache distribuido que maneja diferentes configuraciones
/// según el endpoint y tipo de datos
class DistributedCacheInterceptor extends Interceptor {
  final CacheService _cacheService;
  Map<String, DioCacheInterceptor>? _interceptors;
  
  DistributedCacheInterceptor(this._cacheService);
  
  /// Inicializa los interceptores específicos por tipo de endpoint
  void _initializeInterceptors() {
    if (_interceptors != null) return; // Ya inicializado
    
    _interceptors = {
      'status': DioCacheInterceptor(
        options: _cacheService.getCacheOptionsForEndpoint('/status'),
      ),
      'image': DioCacheInterceptor(
        options: _cacheService.getCacheOptionsForEndpoint('/image'),
      ),
      'analytics': DioCacheInterceptor(
        options: _cacheService.getCacheOptionsForEndpoint('/analytics'),
      ),
      'default': DioCacheInterceptor(
        options: _cacheService.getCacheOptionsForEndpoint('/default'),
      ),
    };
  }
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // Inicializar interceptores si es necesario
      _initializeInterceptors();
      
      // Determinar el tipo de endpoint
      final endpointType = _getEndpointType(options.path);
      
      // Obtener el interceptor apropiado
      final interceptor = _interceptors![endpointType] ?? _interceptors!['default']!;
      
      // Agregar headers de cache
      if (!kIsWeb) {
        options.headers['X-Cache-Type'] = endpointType;
        options.headers['X-Cache-Strategy'] = _getCacheStrategy(endpointType);
      }
      
      // Delegar al interceptor específico
      interceptor.onRequest(options, handler);
      
      Logger.debug('Cache interceptor aplicado para $endpointType: ${options.path}');
    } catch (e) {
      Logger.error('Error en cache interceptor onRequest', e);
      handler.next(options); // Continuar sin cache en caso de error
    }
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      // Inicializar interceptores si es necesario
      _initializeInterceptors();
      
      // Determinar el tipo de endpoint
      final endpointType = _getEndpointType(response.requestOptions.path);
      
      // Obtener el interceptor apropiado
      final interceptor = _interceptors![endpointType] ?? _interceptors!['default']!;
      
      // Agregar headers de respuesta de cache
      response.headers.add('X-Cache-Hit', _wasCacheHit(response).toString());
      response.headers.add('X-Cache-Type', endpointType);
      
      // Delegar al interceptor específico
      interceptor.onResponse(response, handler);
      
      Logger.debug('Cache response procesado para $endpointType: ${response.statusCode}');
    } catch (e) {
      Logger.error('Error en cache interceptor onResponse', e);
      handler.next(response); // Continuar sin cache en caso de error
    }
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      // Inicializar interceptores si es necesario
      _initializeInterceptors();
      
      // Determinar el tipo de endpoint
      final endpointType = _getEndpointType(err.requestOptions.path);
      
      // Obtener el interceptor apropiado
      final interceptor = _interceptors![endpointType] ?? _interceptors!['default']!;
      
      // Delegar al interceptor específico
      interceptor.onError(err, handler);
      
      Logger.debug('Cache error procesado para $endpointType: ${err.message}');
    } catch (e) {
      Logger.error('Error en cache interceptor onError', e);
      handler.next(err); // Continuar sin cache en caso de error
    }
  }
  
  /// Determina el tipo de endpoint basado en la ruta
  String _getEndpointType(String path) {
    if (path.contains('/status')) {
      return 'status';
    } else if (path.contains('/image') || path.contains('/img')) {
      return 'image';
    } else if (path.contains('/analytics') || path.contains('/stats')) {
      return 'analytics';
    }
    
    return 'default';
  }
  
  /// Obtiene la estrategia de cache para un tipo de endpoint
  String _getCacheStrategy(String endpointType) {
    switch (endpointType) {
      case 'status':
        return 'cache_first_30s';
      case 'image':
        return 'cache_first_24h';
      case 'analytics':
        return 'request_15m';
      default:
        return 'request_5m';
    }
  }
  
  /// Verifica si la respuesta fue servida desde cache
  bool _wasCacheHit(Response response) {
    // Verificar headers de cache hit
    final cacheControl = response.headers.value('cache-control');
    final age = response.headers.value('age');
    
    return cacheControl?.contains('max-age') == true || age != null;
  }
}

/// Interceptor para cache warming (precarga de cache)
class CacheWarmupInterceptor extends Interceptor {
  final CacheService _cacheService;
  final List<String> _criticalEndpoints;
  
  CacheWarmupInterceptor(
    this._cacheService, {
    List<String>? criticalEndpoints,
  }) : _criticalEndpoints = criticalEndpoints ?? [
    '/functions/v1/pepito-proxy/status',
    '/functions/v1/pepito-proxy/analytics',
  ];
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Verificar si es un endpoint crítico y si necesita warmup
    if (_criticalEndpoints.contains(options.path)) {
      _scheduleWarmup(options.path);
    }
    
    handler.next(options);
  }
  
  /// Programa el warmup de cache para un endpoint
  void _scheduleWarmup(String endpoint) {
    // Implementar warmup asíncrono sin bloquear la request actual
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        await _cacheService.warmupCache([endpoint]);
      } catch (e) {
        Logger.error('Error en cache warmup para $endpoint', e);
      }
    });
  }
}

/// Interceptor para optimización automática de cache
class CacheOptimizationInterceptor extends Interceptor {
  final CacheService _cacheService;
  int _requestCount = 0;
  static const int _optimizationThreshold = 100;
  
  CacheOptimizationInterceptor(this._cacheService);
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _requestCount++;
    
    // Optimizar cache cada cierto número de requests
    if (_requestCount >= _optimizationThreshold) {
      _requestCount = 0;
      _scheduleOptimization();
    }
    
    handler.next(response);
  }
  
  /// Programa la optimización de cache
  void _scheduleOptimization() {
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        await _cacheService.optimizeCache();
        Logger.info('Cache optimizado automáticamente');
      } catch (e) {
        Logger.error('Error en optimización automática de cache', e);
      }
    });
  }
}

/// Interceptor para métricas de cache
class CacheMetricsInterceptor extends Interceptor {
  final Map<String, int> _hitCount = {};
  final Map<String, int> _missCount = {};
  final Map<String, Duration> _responseTime = {};
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Marcar tiempo de inicio
    options.extra['cache_start_time'] = DateTime.now();
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['cache_start_time'] as DateTime?;
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _responseTime[response.requestOptions.path] = duration;
    }
    
    // Determinar si fue cache hit o miss
    final wasCacheHit = response.headers.value('X-Cache-Hit') == 'true';
    final endpoint = response.requestOptions.path;
    
    if (wasCacheHit) {
      _hitCount[endpoint] = (_hitCount[endpoint] ?? 0) + 1;
    } else {
      _missCount[endpoint] = (_missCount[endpoint] ?? 0) + 1;
    }
    
    handler.next(response);
  }
  
  /// Obtiene métricas de cache
  Map<String, dynamic> getMetrics() {
    final totalHits = _hitCount.values.fold(0, (sum, count) => sum + count);
    final totalMisses = _missCount.values.fold(0, (sum, count) => sum + count);
    final totalRequests = totalHits + totalMisses;
    
    return {
      'total_requests': totalRequests,
      'total_hits': totalHits,
      'total_misses': totalMisses,
      'hit_ratio': totalRequests > 0 ? totalHits / totalRequests : 0.0,
      'hit_count_by_endpoint': Map<String, int>.from(_hitCount),
      'miss_count_by_endpoint': Map<String, int>.from(_missCount),
      'average_response_time': _getAverageResponseTime(),
    };
  }
  
  /// Calcula el tiempo promedio de respuesta
  double _getAverageResponseTime() {
    if (_responseTime.isEmpty) return 0.0;
    
    final totalMs = _responseTime.values
        .map((duration) => duration.inMilliseconds)
        .fold(0, (sum, ms) => sum + ms);
    
    return totalMs / _responseTime.length;
  }
  
  /// Limpia las métricas
  void clearMetrics() {
    _hitCount.clear();
    _missCount.clear();
    _responseTime.clear();
  }
}
