import 'package:flutter/material.dart';
import '../services/security_logging_service.dart';
import '../services/security_monitor_service.dart';
import '../utils/theme_utils.dart';
import '../utils/logger.dart';

class SecurityMonitorScreen extends StatefulWidget {
  const SecurityMonitorScreen({super.key});

  @override
  State<SecurityMonitorScreen> createState() => _SecurityMonitorScreenState();
}

class _SecurityMonitorScreenState extends State<SecurityMonitorScreen>
    with TickerProviderStateMixin {
  final SecurityLoggingService _securityLogger = SecurityLoggingService.instance;
  final SecurityMonitorService _securityMonitor = SecurityMonitorService();
  
  List<SecurityLogEntry> _recentLogs = [];
  Map<String, dynamic> _securityStats = {};
  List<SecurityEvent> _securityEvents = [];
  bool _isLoading = true;
  String? _error;
  
  late TabController _tabController;
  int? _selectedSeverity;
  SecurityEventType? _selectedEventType;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _setupRealTimeUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _securityLogger.initialize();
      
      final results = await Future.wait([
        Future.value(_securityLogger.getLogs(limit: 50)),
        Future.value(_securityLogger.getSecurityStats()),
        Future.value(_securityMonitor.getRecentEvents(limit: 50)),
      ]);

      setState(() {
        _recentLogs = results[0] as List<SecurityLogEntry>;
        _securityStats = results[1] as Map<String, dynamic>;
        _securityEvents = results[2] as List<SecurityEvent>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      Logger.error('Error cargando datos de seguridad', e);
    }
  }

  void _setupRealTimeUpdates() {
    _securityLogger.logStream.listen((logEntry) {
      if (mounted) {
        setState(() {
          _recentLogs.insert(0, logEntry);
          if (_recentLogs.length > 50) {
            _recentLogs.removeLast();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(
              child: _buildTabBarView(),
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
            'Monitor de Seguridad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryColor,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'Resumen', icon: Icon(Icons.dashboard)),
          Tab(text: 'Logs', icon: Icon(Icons.list)),
          Tab(text: 'Alertas', icon: Icon(Icons.warning)),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildLogsTab(),
        _buildAlertsTab(),
      ],
    );
  }

  Widget _buildErrorView() {
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
              const Text(
                'Error cargando datos de seguridad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSecurityStatusCard(),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 16),
          _buildRecentAlertsCard(),
        ],
      ),
    );
  }

  Widget _buildSecurityStatusCard() {
    final criticalEvents = _securityStats['criticalEvents24h'] ?? 0;
    final authFailures = _securityStats['authFailures24h'] ?? 0;
    final rateLimitViolations = _securityStats['rateLimitViolations24h'] ?? 0;
    
    Color statusColor = Colors.green;
    String statusText = 'Seguro';
    IconData statusIcon = Icons.security;
    
    if (criticalEvents > 5 || authFailures > 10) {
      statusColor = Colors.red;
      statusText = 'Crítico';
      statusIcon = Icons.warning;
    } else if (criticalEvents > 0 || authFailures > 5 || rateLimitViolations > 20) {
      statusColor = Colors.orange;
      statusText = 'Alerta';
      statusIcon = Icons.info;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado de Seguridad',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Últimas 24h',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat('Críticos', criticalEvents.toString(), Colors.red),
                _buildQuickStat('Auth Fallos', authFailures.toString(), Colors.orange),
                _buildQuickStat('Rate Limit', rateLimitViolations.toString(), Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Eventos',
          '${_securityStats['totalEvents'] ?? 0}',
          Icons.event,
          Colors.blue,
        ),
        _buildStatCard(
          'Eventos 7d',
          '${_securityStats['events7d'] ?? 0}',
          Icons.calendar_view_week,
          Colors.green,
        ),
        _buildStatCard(
          'Eventos Críticos',
          '${_securityEvents.where((e) => e.severity >= 8).length}',
          Icons.shield,
          Colors.red,
        ),
        _buildStatCard(
          'Eventos Recientes',
          '${_securityEvents.length}',
          Icons.people,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsCard() {
    final recentCriticalEvents = _securityEvents
        .where((event) => event.severity >= 7)
        .take(5)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Alertas Recientes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentCriticalEvents.isEmpty)
              const Text(
                'No hay alertas críticas recientes',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              )
            else
              ...recentCriticalEvents.map((event) => _buildSecurityEventItem(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityEventItem(SecurityEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForEventType(event.type),
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatTimestamp(event.timestamp),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getColorForSeverity(event.severity).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'SEV ${event.severity}',
              style: TextStyle(
                color: _getColorForSeverity(event.severity),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    final filteredEvents = _getFilteredEvents();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedSeverity,
                  decoration: const InputDecoration(
                    labelText: 'Severidad',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                  dropdownColor: Colors.grey.shade800,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todas', style: TextStyle(color: Colors.white)),
                    ),
                    ...List.generate(10, (i) => i + 1).map((severity) => DropdownMenuItem(
                      value: severity,
                      child: Text(
                        'Severidad $severity',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSeverity = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<SecurityEventType?>(
                  value: _selectedEventType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                  dropdownColor: Colors.grey.shade800,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todos', style: TextStyle(color: Colors.white)),
                    ),
                    ...SecurityEventType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedEventType = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              return _buildEventItem(filteredEvents[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(SecurityEvent event) {
    return Card(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          leading: Icon(
            _getIconForEventType(event.type),
            color: _getColorForSeverity(event.severity),
          ),
          title: Text(
            event.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${_formatTimestamp(event.timestamp)} • ${event.type.name}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getColorForSeverity(event.severity).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'SEV ${event.severity}',
              style: TextStyle(
                color: _getColorForSeverity(event.severity),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Tipo', event.type.name),
                  _buildDetailRow('Severidad', event.severity.toString()),
                  const SizedBox(height: 8),
                  if (event.metadata != null && event.metadata!.isNotEmpty) ...[
                    const Text(
                      'Detalles:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatEventDetails(event.metadata!),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    final alertEvents = _securityEvents
        .where((event) => event.severity >= 7)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alertEvents.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(alertEvents[index]);
      },
    );
  }

  Widget _buildAlertCard(SecurityEvent event) {
    return Card(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _getColorForSeverity(event.severity),
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: _getColorForSeverity(event.severity),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorForSeverity(event.severity).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SEV ${event.severity}',
                    style: TextStyle(
                      color: _getColorForSeverity(event.severity),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(event.timestamp),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tipo: ${event.type.name}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (event.metadata != null && event.metadata!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Detalles:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatEventDetails(event.metadata!),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Logs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedSeverity,
              decoration: const InputDecoration(labelText: 'Severidad'),
              items: List.generate(10, (i) => i + 1).map((severity) {
                return DropdownMenuItem(
                  value: severity,
                  child: Text('Severidad $severity'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSeverity = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SecurityEventType>(
              value: _selectedEventType,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: SecurityEventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedEventType = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedSeverity = null;
                _selectedEventType = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  List<SecurityEvent> _getFilteredEvents() {
    var filtered = List<SecurityEvent>.from(_securityEvents);
    
    if (_selectedSeverity != null) {
      filtered = filtered.where((event) => event.severity == _selectedSeverity).toList();
    }
    
    if (_selectedEventType != null) {
      filtered = filtered.where((event) => event.type == _selectedEventType).toList();
    }
    
    return filtered;
  }

  Color _getColorForSeverity(int severity) {
    if (severity >= 9) return Colors.red.shade900;
    if (severity >= 7) return Colors.red.shade700;
    if (severity >= 5) return Colors.orange.shade700;
    if (severity >= 3) return Colors.orange.shade500;
    if (severity >= 1) return Colors.blue.shade500;
    return Colors.grey.shade500;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatEventDetails(Map<String, dynamic> metadata) {
    return metadata.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  IconData _getIconForEventType(SecurityEventType type) {
    switch (type) {
      case SecurityEventType.authenticationFailure:
        return Icons.login;
      case SecurityEventType.unauthorizedAccess:
        return Icons.security;
      case SecurityEventType.dataValidationFailure:
        return Icons.data_usage;
      case SecurityEventType.rateLimitViolation:
        return Icons.speed;
      case SecurityEventType.suspiciousActivity:
        return Icons.warning;
      case SecurityEventType.invalidInput:
        return Icons.shield;
      default:
        return Icons.error;
    }
  }

}
