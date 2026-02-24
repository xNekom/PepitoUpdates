import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/hybrid_pepito_provider.dart';

/// Widget que muestra el estado del sistema y permite cambiar el modo de operación
class SystemStatusWidget extends ConsumerWidget {
  const SystemStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSource = ref.watch(pepitoDataSourceProvider);
    final systemStatus = ref.watch(systemStatusProvider);
    final statusNotifier = ref.read(hybridPepitoStatusProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_system_daydream,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado del Sistema',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Modo actual
            _buildStatusRow(
              'Modo de operación:',
              _getDataSourceDisplayName(dataSource),
              _getDataSourceIcon(dataSource),
              _getDataSourceColor(dataSource),
            ),
            
            const SizedBox(height: 8),
            
            // Estado de carga
            _buildStatusRow(
              'Estado:',
              systemStatus['isLoading'] ? 'Cargando...' : 
              systemStatus['hasError'] ? 'Error' : 'Activo',
              systemStatus['isLoading'] ? Icons.refresh : 
              systemStatus['hasError'] ? Icons.error : Icons.check_circle,
              systemStatus['isLoading'] ? Colors.orange : 
              systemStatus['hasError'] ? Colors.red : Colors.green,
            ),
            
            const SizedBox(height: 8),
            
            // Última actualización
            if (systemStatus['lastUpdate'] != null)
              _buildStatusRow(
                'Última actualización:',
                _formatDateTime(systemStatus['lastUpdate']),
                Icons.access_time,
                Colors.grey[600]!,
              ),
            
            const SizedBox(height: 16),
            
            // Modo fijo: Cloud Functions
            Text(
              'Modo: Cloud Functions (Fijo)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Los datos se obtienen desde Supabase, actualizados por Cloud Functions. Funciona 24/7.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => statusNotifier.refresh(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Actualizar'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showSystemInfo(context, systemStatus),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Info'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
  
  String _getDataSourceDisplayName(PepitoDataSource source) {
    switch (source) {
      case PepitoDataSource.localPolling:
        return 'Polling Local';
      case PepitoDataSource.cloudFunctions:
        return 'Cloud Functions';
      case PepitoDataSource.hybrid:
        return 'Híbrido';
    }
  }
  
  IconData _getDataSourceIcon(PepitoDataSource source) {
    switch (source) {
      case PepitoDataSource.localPolling:
        return Icons.phone_android;
      case PepitoDataSource.cloudFunctions:
        return Icons.cloud;
      case PepitoDataSource.hybrid:
        return Icons.sync;
    }
  }
  
  Color _getDataSourceColor(PepitoDataSource source) {
    switch (source) {
      case PepitoDataSource.localPolling:
        return Colors.blue;
      case PepitoDataSource.cloudFunctions:
        return Colors.green;
      case PepitoDataSource.hybrid:
        return Colors.orange;
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Hace ${difference.inSeconds} segundos';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
  
  void _showSystemInfo(BuildContext context, Map<String, dynamic> systemStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del Sistema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Fuente de datos:', systemStatus['dataSource']),
            _buildInfoRow('Estado de carga:', systemStatus['isLoading'].toString()),
            _buildInfoRow('Tiene errores:', systemStatus['hasError'].toString()),
            if (systemStatus['lastUpdate'] != null)
              _buildInfoRow('Última actualización:', systemStatus['lastUpdate'].toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

/// Widget compacto para mostrar solo el estado actual
class CompactSystemStatusWidget extends ConsumerWidget {
  const CompactSystemStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSource = ref.watch(pepitoDataSourceProvider);
    final systemStatus = ref.watch(systemStatusProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getDataSourceColor(dataSource).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getDataSourceColor(dataSource).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getDataSourceIcon(dataSource),
            size: 14,
            color: _getDataSourceColor(dataSource),
          ),
          const SizedBox(width: 4),
          Text(
            _getDataSourceDisplayName(dataSource),
            style: TextStyle(
              fontSize: 12,
              color: _getDataSourceColor(dataSource),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (systemStatus['isLoading']) ...[
            const SizedBox(width: 4),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(
                  _getDataSourceColor(dataSource),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _getDataSourceDisplayName(PepitoDataSource source) {
    switch (source) {
      case PepitoDataSource.localPolling:
        return 'Local';
      case PepitoDataSource.cloudFunctions:
        return 'Cloud';
      case PepitoDataSource.hybrid:
        return 'Híbrido';
    }
  }
  
  IconData _getDataSourceIcon(PepitoDataSource source) {
    switch (source) {
      case PepitoDataSource.localPolling:
        return Icons.phone_android;
      case PepitoDataSource.cloudFunctions:
        return Icons.cloud;
      case PepitoDataSource.hybrid:
        return Icons.sync;
    }
  }
  
  Color _getDataSourceColor(PepitoDataSource source) {
    switch (source) {
      case PepitoDataSource.localPolling:
        return Colors.blue;
      case PepitoDataSource.cloudFunctions:
        return Colors.green;
      case PepitoDataSource.hybrid:
        return Colors.orange;
    }
  }
}