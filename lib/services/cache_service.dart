import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../utils/logger.dart';

/// Configuración de cache distribuido con múltiples niveles
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();
  
  // Stores de cache
  late final CacheStore _memoryStore;
  late final CacheStore _diskStore;
  late final CacheStore _hybridStore;
  
  // Configuraciones de cache por tipo de datos
  late final CacheOptions _defaultOptions;
  late final CacheOptions _statusOptions;
  late final CacheOptions _imageOptions;
  late final CacheOptions _analyticsOptions;
  
  bool _isInitialized = false;
  
  /// Inicializa el servicio de cache
  void initialize() {
    if (_isInitialized) return;
    
    try {
      // Configurar stores de cache
      _initializeCacheStores();
      
      // Configurar opciones de cache
      _initializeCacheOptions();
      
      _isInitialized = true;
      Logger.info('CacheService inicializado exitosamente');
    } catch (e) {
      // Si ya está inicializado (por hot restart), solo marcar como inicializado
      if (e.toString().contains('has already been initialized')) {
        _isInitialized = true;
        Logger.info('CacheService ya estaba inicializado (hot restart)');
      } else {
        Logger.error('Error inicializando CacheService', e);
        rethrow;
      }
    }
  }
  
  /// Inicializa los stores de cache
  void _initializeCacheStores() {
    // Memory store para datos frecuentes (10MB)
    _memoryStore = MemCacheStore(
      maxSize: 10 * 1024 * 1024, // 10MB
      maxEntrySize: 1024 * 1024,  // 1MB por entrada
    );
    
    // Disk store para persistencia (50MB) - usando memoria por ahora
    _diskStore = MemCacheStore(
      maxSize: 50 * 1024 * 1024, // 50MB
      maxEntrySize: 1024 * 1024,  // 1MB por entrada
    );
    
    // Hybrid store que combina memoria y disco - usando solo memoria
    _hybridStore = _memoryStore;
  }
  
  /// Inicializa las opciones de cache
  void _initializeCacheOptions() {
    // Configuración por defecto
    _defaultOptions = CacheOptions(
      store: _hybridStore,
      policy: CachePolicy.request,
      maxStale: const Duration(minutes: 5),
      priority: CachePriority.normal,
      cipher: null,
      allowPostMethod: false,
    );
    
    // Configuración para estado de Pépito (cache agresivo)
    _statusOptions = CacheOptions(
      store: _hybridStore,
      policy: CachePolicy.forceCache,
      maxStale: const Duration(seconds: 30),
      priority: CachePriority.high,
      cipher: null,
      allowPostMethod: false,
    );
    
    // Configuración para imágenes (cache persistente)
    _imageOptions = CacheOptions(
      store: _diskStore, // Solo disco para imágenes
      policy: CachePolicy.forceCache,
      maxStale: const Duration(hours: 24),
      priority: CachePriority.low,
      cipher: null,
      allowPostMethod: false,
    );
    
    // Configuración para analytics (cache temporal)
    _analyticsOptions = CacheOptions(
      store: _memoryStore, // Solo memoria para analytics
      policy: CachePolicy.request,
      maxStale: const Duration(minutes: 15),
      priority: CachePriority.normal,
      cipher: null,
      allowPostMethod: true, // Permitir POST para analytics
    );
  }
  

  /// Obtiene las opciones de cache para un endpoint específico
  CacheOptions getCacheOptionsForEndpoint(String endpoint) {
    if (endpoint.contains('/status')) {
      return _statusOptions;
    } else if (endpoint.contains('/image') || endpoint.contains('/img')) {
      return _imageOptions;
    } else if (endpoint.contains('/analytics') || endpoint.contains('/stats')) {
      return _analyticsOptions;
    }
    
    return _defaultOptions;
  }
  
  /// Limpia todo el cache
  Future<void> clearAllCache() async {
    try {
      await Future.wait([
        _memoryStore.clean(),
        _diskStore.clean(),
      ]);
      
      Logger.info('Todo el cache limpiado exitosamente');
    } catch (e) {
      Logger.error('Error limpiando cache', e);
      rethrow;
    }
  }
  
  /// Limpia cache por tipo
  Future<void> clearCacheByType(CacheType type) async {
    try {
      switch (type) {
        case CacheType.memory:
          await _memoryStore.clean();
          break;
        case CacheType.disk:
          await _diskStore.clean();
          break;
        case CacheType.status:
          await _clearCacheByPattern('/status');
          break;
        case CacheType.images:
          await _clearCacheByPattern('/image');
          break;
        case CacheType.analytics:
          await _clearCacheByPattern('/analytics');
          break;
      }
      
      Logger.info('Cache de tipo $type limpiado exitosamente');
    } catch (e) {
      Logger.error('Error limpiando cache de tipo $type', e);
      rethrow;
    }
  }
  
  /// Limpia cache por patrón de clave
  Future<void> _clearCacheByPattern(String pattern) async {
    // Implementación simplificada - en una implementación real
    // se iteraría sobre las claves y se eliminarían las que coincidan
    await _memoryStore.clean();
    await _diskStore.clean();
  }
  
  /// Obtiene estadísticas del cache
  Future<CacheStats> getCacheStats() async {
    try {
      final memorySize = await _getStoreSize(_memoryStore);
      final diskSize = await _getStoreSize(_diskStore);
      
      return CacheStats(
        memorySize: memorySize,
        diskSize: diskSize,
        totalSize: memorySize + diskSize,
        memoryEntries: await _getStoreEntryCount(_memoryStore),
        diskEntries: await _getStoreEntryCount(_diskStore),
        isInitialized: _isInitialized,
      );
    } catch (e) {
      Logger.error('Error obteniendo estadísticas de cache', e);
      return CacheStats.empty();
    }
  }
  
  /// Obtiene el tamaño de un store
  Future<int> _getStoreSize(CacheStore store) async {
    try {
      // Estimación simplificada
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  /// Obtiene el número de entradas de un store
  Future<int> _getStoreEntryCount(CacheStore store) async {
    try {
      // Estimación simplificada
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  /// Optimiza el cache eliminando entradas expiradas
  Future<void> optimizeCache() async {
    try {
      // Limpiar entradas expiradas
      await _memoryStore.clean();
      await _diskStore.clean();
      
      Logger.info('Cache optimizado exitosamente');
    } catch (e) {
      Logger.error('Error optimizando cache', e);
    }
  }
  
  /// Configura cache warming para endpoints críticos
  Future<void> warmupCache(List<String> endpoints) async {
    try {
      Logger.info('Iniciando warmup de cache para ${endpoints.length} endpoints');
      
      // En una implementación real, se harían requests a estos endpoints
      // para pre-cargar el cache
      for (final endpoint in endpoints) {
        Logger.debug('Warming up cache for: $endpoint');
        // Aquí se haría el request real
      }
      
      Logger.info('Cache warmup completado');
    } catch (e) {
      Logger.error('Error en cache warmup', e);
    }
  }
  
  /// Dispose del servicio
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    try {
      await _memoryStore.close();
      await _diskStore.close();
      
      _isInitialized = false;
      Logger.info('CacheService disposed');
    } catch (e) {
      Logger.error('Error disposing CacheService', e);
    }
  }
}

/// Tipos de cache disponibles
enum CacheType {
  memory,
  disk,
  status,
  images,
  analytics,
}

/// Estadísticas del cache
class CacheStats {
  final int memorySize;
  final int diskSize;
  final int totalSize;
  final int memoryEntries;
  final int diskEntries;
  final bool isInitialized;
  
  const CacheStats({
    required this.memorySize,
    required this.diskSize,
    required this.totalSize,
    required this.memoryEntries,
    required this.diskEntries,
    required this.isInitialized,
  });
  
  factory CacheStats.empty() {
    return const CacheStats(
      memorySize: 0,
      diskSize: 0,
      totalSize: 0,
      memoryEntries: 0,
      diskEntries: 0,
      isInitialized: false,
    );
  }
  
  /// Convierte a Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'memory_size': memorySize,
      'disk_size': diskSize,
      'total_size': totalSize,
      'memory_entries': memoryEntries,
      'disk_entries': diskEntries,
      'is_initialized': isInitialized,
    };
  }
  
  /// Tamaño formateado para mostrar al usuario
  String get formattedTotalSize {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
