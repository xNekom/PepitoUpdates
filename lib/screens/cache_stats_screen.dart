import 'package:flutter/material.dart';
import '../services/cache_service.dart';
import '../services/secure_api_service.dart';
import '../utils/theme_utils.dart';
import '../utils/logger.dart';

class CacheStatsScreen extends StatefulWidget {
  const CacheStatsScreen({super.key});

  @override
  State<CacheStatsScreen> createState() => _CacheStatsScreenState();
}

class _CacheStatsScreenState extends State<CacheStatsScreen> {
  CacheStats? _cacheStats;
  Map<String, dynamic>? _apiStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final cacheService = CacheService.instance;
      final secureApiService = SecureApiService();

      final results = await Future.wait([
        cacheService.getCacheStats(),
        secureApiService.getCacheStats(),
      ]);

      setState(() {
        _cacheStats = results[0] as CacheStats;
        _apiStats = results[1] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      Logger.error('Error cargando estadísticas de cache', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'Estadísticas de Cache',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error cargando estadísticas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadStats,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 16),
          _buildStorageCard(),
          const SizedBox(height: 16),
          _buildPerformanceCard(),
          const SizedBox(height: 16),
          _buildActionsCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resumen General',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Estado del Cache',
              _cacheStats?.isInitialized == true ? 'Activo' : 'Inactivo',
              _cacheStats?.isInitialized == true ? Colors.green : Colors.red,
            ),
            _buildStatRow(
              'Tamaño Total',
              _cacheStats?.formattedTotalSize ?? '0B',
              Colors.blue,
            ),
            _buildStatRow(
              'Entradas Totales',
              '${(_cacheStats?.memoryEntries ?? 0) + (_cacheStats?.diskEntries ?? 0)}',
              Colors.orange,
            ),
            _buildStatRow(
              'Rate Limit Entries',
              '${_apiStats?['rate_limit_entries'] ?? 0}',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Almacenamiento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStorageBar(
              'Memoria',
              _cacheStats?.memorySize ?? 0,
              _cacheStats?.memoryEntries ?? 0,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildStorageBar(
              'Disco',
              _cacheStats?.diskSize ?? 0,
              _cacheStats?.diskEntries ?? 0,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageBar(String label, int size, int entries, Color color) {
    final maxSize = 50 * 1024 * 1024; // 50MB máximo
    final percentage = size / maxSize;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$entries entradas',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatBytes(size),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rendimiento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Usuario Autenticado',
              _apiStats?['authenticated'] == true ? 'Sí' : 'No',
              _apiStats?['authenticated'] == true ? Colors.green : Colors.orange,
            ),
            _buildStatRow(
              'ID de Usuario',
              _apiStats?['user_id']?.toString() ?? 'N/A',
              Colors.blue,
            ),
            if (_apiStats?['cache_stats'] != null) ...
              _buildCacheStatsFromApi(_apiStats!['cache_stats']),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCacheStatsFromApi(Map<String, dynamic> cacheStats) {
    return [
      _buildStatRow(
        'Memoria API',
        _formatBytes(cacheStats['memory_size'] ?? 0),
        Colors.green,
      ),
      _buildStatRow(
        'Disco API',
        _formatBytes(cacheStats['disk_size'] ?? 0),
        Colors.blue,
      ),
      _buildStatRow(
        'Total API',
        _formatBytes(cacheStats['total_size'] ?? 0),
        Colors.purple,
      ),
    ];
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Acciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _optimizeCache,
                    icon: const Icon(Icons.tune),
                    label: const Text('Optimizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _warmupCache,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Precarga'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _clearAllCache,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar Todo el Cache'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Future<void> _optimizeCache() async {
    try {
      final cacheService = CacheService.instance;
      await cacheService.optimizeCache();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache optimizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadStats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error optimizando cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _warmupCache() async {
    try {
      final secureApiService = SecureApiService();
      await secureApiService.warmupCache();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Precarga de cache completada'),
            backgroundColor: Colors.green,
          ),
        );
        _loadStats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en precarga: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que quieres limpiar todo el cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final cacheService = CacheService.instance;
        await cacheService.clearAllCache();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todo el cache limpiado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadStats();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error limpiando cache: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
