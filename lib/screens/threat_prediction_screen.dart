import 'package:flutter/material.dart';
import '../services/threat_prediction_service.dart';

class ThreatPredictionScreen extends StatefulWidget {
  const ThreatPredictionScreen({super.key});

  @override
  State<ThreatPredictionScreen> createState() => _ThreatPredictionScreenState();
}

class _ThreatPredictionScreenState extends State<ThreatPredictionScreen>
    with TickerProviderStateMixin {
  final ThreatPredictionService _predictionService = ThreatPredictionService.instance;
  
  List<ThreatPrediction> _predictions = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  RiskLevel? _selectedRiskFilter;
  ThreatType? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    
    // Actualizar datos cada 30 segundos
    Future.delayed(const Duration(seconds: 30), _autoRefresh);
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

      await _predictionService.initialize();
      
      // Ejecutar análisis predictivo
      await _predictionService.runPredictiveAnalysis();
      
      // Obtener predicciones y estadísticas
      final predictions = _predictionService.getActivePredictions();
      final stats = _predictionService.getPredictionStats();

      setState(() {
        _predictions = predictions;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _autoRefresh() async {
    if (mounted) {
      await _loadData();
      Future.delayed(const Duration(seconds: 30), _autoRefresh);
    }
  }

  List<ThreatPrediction> get _filteredPredictions {
    var filtered = _predictions;
    
    if (_selectedRiskFilter != null) {
      filtered = filtered.where((p) => p.riskLevel == _selectedRiskFilter).toList();
    }
    
    if (_selectedTypeFilter != null) {
      filtered = filtered.where((p) => p.type == _selectedTypeFilter).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción de Amenazas'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'run_analysis',
                child: Text('Ejecutar Análisis'),
              ),
              const PopupMenuItem(
                value: 'export_predictions',
                child: Text('Exportar Predicciones'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Predicciones', icon: Icon(Icons.warning)),
            Tab(text: 'Estadísticas', icon: Icon(Icons.analytics)),
            Tab(text: 'Configuración', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPredictionsTab(),
                    _buildStatsTab(),
                    _buildConfigTab(),
                  ],
                ),
    );
  }

  Widget _buildPredictionsTab() {
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _filteredPredictions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security,
                        size: 64,
                        color: Colors.green,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No se detectaron amenazas inminentes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'El sistema está monitoreando continuamente',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredPredictions.length,
                  itemBuilder: (context, index) {
                    return _buildPredictionCard(_filteredPredictions[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<RiskLevel?>(
              value: _selectedRiskFilter,
              decoration: const InputDecoration(
                labelText: 'Filtrar por Riesgo',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<RiskLevel?>(
                  value: null,
                  child: Text('Todos los niveles'),
                ),
                ...RiskLevel.values.map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(_getRiskLevelText(level)),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRiskFilter = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<ThreatType?>(
              value: _selectedTypeFilter,
              decoration: const InputDecoration(
                labelText: 'Filtrar por Tipo',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<ThreatType?>(
                  value: null,
                  child: Text('Todos los tipos'),
                ),
                ...ThreatType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getThreatTypeText(type)),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTypeFilter = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(ThreatPrediction prediction) {
    final riskColor = _getRiskColor(prediction.riskLevel);
    final timeUntil = prediction.predictedTime.difference(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: riskColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getThreatIcon(prediction.type),
                    color: riskColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getThreatTypeText(prediction.type),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: riskColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRiskLevelText(prediction.riskLevel),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    timeUntil.isNegative
                        ? 'Tiempo estimado: Pasado'
                        : 'Tiempo estimado: ${_formatDuration(timeUntil)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.analytics, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Confianza: ${(prediction.confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (prediction.sourceIp != null) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'IP Origen: ${prediction.sourceIp}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (prediction.targetEndpoint != null) ...[
                Row(
                  children: [
                    Icon(Icons.api, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Endpoint: ${prediction.targetEndpoint}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              const Divider(),
              const Text(
                'Recomendaciones:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...prediction.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(rec)),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showPredictionDetails(prediction),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Ver Detalles'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _handleThreatResponse(prediction),
                    icon: const Icon(Icons.security),
                    label: const Text('Responder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: riskColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(
            'Resumen General',
            [
              _buildStatRow('Total de Predicciones', '${_stats['total_predictions'] ?? 0}'),
              _buildStatRow('Últimas 24h', '${_stats['predictions_last_24h'] ?? 0}'),
              _buildStatRow('Confianza Promedio', 
                '${((_stats['average_confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatsCard(
            'Por Tipo de Amenaza',
            (_stats['by_type'] as Map<String, dynamic>? ?? {})
                .entries
                .map((e) => _buildStatRow(
                  _getThreatTypeText(_parseThreatType(e.key)),
                  '${e.value}',
                ))
                .toList(),
          ),
          const SizedBox(height: 16),
          _buildStatsCard(
            'Por Nivel de Riesgo',
            (_stats['by_risk_level'] as Map<String, dynamic>? ?? {})
                .entries
                .map((e) => _buildStatRow(
                  _getRiskLevelText(_parseRiskLevel(e.key)),
                  '${e.value}',
                ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab() {
    return const Center(
      child: Text(
        'Configuración de predicción\n(Próximamente)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.critical:
        return Colors.red.shade900;
    }
  }

  IconData _getThreatIcon(ThreatType type) {
    switch (type) {
      case ThreatType.bruteForce:
        return Icons.lock_open;
      case ThreatType.sqlInjection:
        return Icons.storage;
      case ThreatType.xssAttack:
        return Icons.code;
      case ThreatType.ddosAttack:
        return Icons.traffic;
      case ThreatType.dataExfiltration:
        return Icons.download;
      case ThreatType.privilegeEscalation:
        return Icons.admin_panel_settings;
      case ThreatType.malwareUpload:
        return Icons.bug_report;
      case ThreatType.sessionHijacking:
        return Icons.person_off;
    }
  }

  String _getThreatTypeText(ThreatType type) {
    switch (type) {
      case ThreatType.bruteForce:
        return 'Ataque de Fuerza Bruta';
      case ThreatType.sqlInjection:
        return 'Inyección SQL';
      case ThreatType.xssAttack:
        return 'Ataque XSS';
      case ThreatType.ddosAttack:
        return 'Ataque DDoS';
      case ThreatType.dataExfiltration:
        return 'Exfiltración de Datos';
      case ThreatType.privilegeEscalation:
        return 'Escalación de Privilegios';
      case ThreatType.malwareUpload:
        return 'Carga de Malware';
      case ThreatType.sessionHijacking:
        return 'Secuestro de Sesión';
    }
  }

  String _getRiskLevelText(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Bajo';
      case RiskLevel.medium:
        return 'Medio';
      case RiskLevel.high:
        return 'Alto';
      case RiskLevel.critical:
        return 'Crítico';
    }
  }

  ThreatType _parseThreatType(String value) {
    return ThreatType.values.firstWhere(
      (type) => type.toString() == value,
      orElse: () => ThreatType.bruteForce,
    );
  }

  RiskLevel _parseRiskLevel(String value) {
    return RiskLevel.values.firstWhere(
      (level) => level.toString() == value,
      orElse: () => RiskLevel.low,
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'run_analysis':
        _runAnalysis();
        break;
      case 'export_predictions':
        _exportPredictions();
        break;
    }
  }

  Future<void> _runAnalysis() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ejecutando análisis predictivo...'),
        duration: Duration(seconds: 2),
      ),
    );
    await _loadData();
  }

  void _exportPredictions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de exportación próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPredictionDetails(ThreatPrediction prediction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de ${_getThreatTypeText(prediction.type)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${prediction.id}'),
              const SizedBox(height: 8),
              Text('Confianza: ${(prediction.confidence * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
              Text('Creado: ${prediction.createdAt}'),
              const SizedBox(height: 8),
              Text('Predicción: ${prediction.predictedTime}'),
              const SizedBox(height: 16),
              const Text('Indicadores:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...prediction.indicators.entries.map((e) => 
                Text('${e.key}: ${e.value}')
              ),
            ],
          ),
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

  void _handleThreatResponse(ThreatPrediction prediction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respuesta a Amenaza'),
        content: Text(
          '¿Deseas activar las medidas de respuesta automática para ${_getThreatTypeText(prediction.type)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _activateResponse(prediction);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getRiskColor(prediction.riskLevel),
              foregroundColor: Colors.white,
            ),
            child: const Text('Activar'),
          ),
        ],
      ),
    );
  }

  void _activateResponse(ThreatPrediction prediction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Respuesta activada para ${_getThreatTypeText(prediction.type)}'),
        backgroundColor: _getRiskColor(prediction.riskLevel),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}