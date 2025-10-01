import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../utils/logger.dart';

/// Niveles de severidad para eventos de seguridad
enum SecurityLogLevel {
  info,
  warning,
  critical,
  emergency,
}

/// Categorías de eventos de seguridad
enum SecurityEventCategory {
  authentication,
  authorization,
  dataAccess,
  networkSecurity,
  rateLimiting,
  inputValidation,
  systemIntegrity,
  compliance,
}

/// Modelo para eventos de seguridad
class SecurityLogEntry {
  final String id;
  final DateTime timestamp;
  final SecurityLogLevel level;
  final SecurityEventCategory category;
  final String event;
  final Map<String, dynamic> details;
  final String? userId;
  final String? sessionId;
  final String? ipAddress;
  final String? userAgent;
  final String checksum;

  SecurityLogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.category,
    required this.event,
    required this.details,
    this.userId,
    this.sessionId,
    this.ipAddress,
    this.userAgent,
    required this.checksum,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'category': category.name,
      'event': event,
      'details': details,
      'userId': userId,
      'sessionId': sessionId,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'checksum': checksum,
    };
  }

  factory SecurityLogEntry.fromJson(Map<String, dynamic> json) {
    return SecurityLogEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      level: SecurityLogLevel.values.firstWhere(
        (e) => e.name == json['level'],
      ),
      category: SecurityEventCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      event: json['event'],
      details: Map<String, dynamic>.from(json['details']),
      userId: json['userId'],
      sessionId: json['sessionId'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      checksum: json['checksum'],
    );
  }

  /// Genera un checksum para verificar la integridad del log
  static String generateChecksum(Map<String, dynamic> data) {
    final content = jsonEncode(data);
    return sha256.convert(utf8.encode(content)).toString();
  }

  /// Verifica la integridad del log
  bool verifyIntegrity() {
    final data = toJson();
    data.remove('checksum');
    return checksum == generateChecksum(data);
  }
}

/// Configuración para el servicio de logging de seguridad
class SecurityLoggingConfig {
  final bool enableFileLogging;
  final bool enableRemoteLogging;
  final bool enableRealTimeAlerts;
  final int maxLogFileSize;
  final int maxLogFiles;
  final Duration logRetentionPeriod;
  final List<SecurityLogLevel> alertLevels;
  final List<SecurityEventCategory> monitoredCategories;
  final String? remoteEndpoint;
  final Map<String, String>? remoteHeaders;

  const SecurityLoggingConfig({
    this.enableFileLogging = true,
    this.enableRemoteLogging = false,
    this.enableRealTimeAlerts = true,
    this.maxLogFileSize = 10 * 1024 * 1024, // 10MB
    this.maxLogFiles = 5,
    this.logRetentionPeriod = const Duration(days: 30),
    this.alertLevels = const [SecurityLogLevel.critical, SecurityLogLevel.emergency],
    this.monitoredCategories = SecurityEventCategory.values,
    this.remoteEndpoint,
    this.remoteHeaders,
  });
}

/// Servicio de logging y monitoreo de seguridad
class SecurityLoggingService {
  static SecurityLoggingService? _instance;
  static SecurityLoggingService get instance {
    _instance ??= SecurityLoggingService._internal();
    return _instance!;
  }

  SecurityLoggingService._internal();

  SecurityLoggingConfig _config = const SecurityLoggingConfig();
  final List<SecurityLogEntry> _memoryBuffer = [];
  final StreamController<SecurityLogEntry> _logStreamController = StreamController.broadcast();
  Timer? _flushTimer;
  File? _currentLogFile;
  bool _isInitialized = false;

  /// Stream de eventos de seguridad en tiempo real
  Stream<SecurityLogEntry> get logStream => _logStreamController.stream;

  /// Inicializa el servicio de logging
  Future<void> initialize({SecurityLoggingConfig? config}) async {
    if (_isInitialized) return;

    _config = config ?? _config;
    
    if (_config.enableFileLogging) {
      await _initializeFileLogging();
    }

    // Configurar flush automático cada 30 segundos
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _flushLogs();
    });

    _isInitialized = true;
    Logger.info('SecurityLoggingService inicializado');
  }

  /// Registra un evento de seguridad
  Future<void> logSecurityEvent({
    required SecurityLogLevel level,
    required SecurityEventCategory category,
    required String event,
    required Map<String, dynamic> details,
    String? userId,
    String? sessionId,
    String? ipAddress,
    String? userAgent,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Filtrar por categorías monitoreadas
    if (!_config.monitoredCategories.contains(category)) {
      return;
    }

    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name,
      'category': category.name,
      'event': event,
      'details': details,
      'userId': userId,
      'sessionId': sessionId,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };

    final logEntry = SecurityLogEntry(
      id: _generateLogId(),
      timestamp: DateTime.now(),
      level: level,
      category: category,
      event: event,
      details: details,
      userId: userId,
      sessionId: sessionId,
      ipAddress: ipAddress,
      userAgent: userAgent,
      checksum: SecurityLogEntry.generateChecksum(logData),
    );

    // Añadir al buffer de memoria
    _memoryBuffer.add(logEntry);

    // Emitir evento en tiempo real
    _logStreamController.add(logEntry);

    // Procesar alertas si es necesario
    if (_config.enableRealTimeAlerts && _config.alertLevels.contains(level)) {
      await _processAlert(logEntry);
    }

    // Logging remoto si está habilitado
    if (_config.enableRemoteLogging) {
      _sendToRemoteEndpoint(logEntry);
    }

    // Flush inmediato para eventos críticos
    if (level == SecurityLogLevel.critical || level == SecurityLogLevel.emergency) {
      await _flushLogs();
    }

    Logger.debug('Evento de seguridad registrado: ${logEntry.event}');
  }

  /// Métodos de conveniencia para diferentes tipos de eventos
  Future<void> logAuthenticationEvent(String event, Map<String, dynamic> details, {String? userId}) async {
    await logSecurityEvent(
      level: SecurityLogLevel.info,
      category: SecurityEventCategory.authentication,
      event: event,
      details: details,
      userId: userId,
    );
  }

  Future<void> logAuthorizationFailure(String event, Map<String, dynamic> details, {String? userId}) async {
    await logSecurityEvent(
      level: SecurityLogLevel.warning,
      category: SecurityEventCategory.authorization,
      event: event,
      details: details,
      userId: userId,
    );
  }

  Future<void> logRateLimitViolation(String event, Map<String, dynamic> details, {String? ipAddress}) async {
    await logSecurityEvent(
      level: SecurityLogLevel.warning,
      category: SecurityEventCategory.rateLimiting,
      event: event,
      details: details,
      ipAddress: ipAddress,
    );
  }

  Future<void> logDataAccessEvent(String event, Map<String, dynamic> details, {String? userId}) async {
    await logSecurityEvent(
      level: SecurityLogLevel.info,
      category: SecurityEventCategory.dataAccess,
      event: event,
      details: details,
      userId: userId,
    );
  }

  Future<void> logSecurityViolation(String event, Map<String, dynamic> details, {String? userId, String? ipAddress}) async {
    await logSecurityEvent(
      level: SecurityLogLevel.critical,
      category: SecurityEventCategory.systemIntegrity,
      event: event,
      details: details,
      userId: userId,
      ipAddress: ipAddress,
    );
  }

  /// Obtiene logs filtrados
  List<SecurityLogEntry> getLogs({
    SecurityLogLevel? level,
    SecurityEventCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    int limit = 100,
  }) {
    var filteredLogs = List<SecurityLogEntry>.from(_memoryBuffer);

    if (level != null) {
      filteredLogs = filteredLogs.where((log) => log.level == level).toList();
    }

    if (category != null) {
      filteredLogs = filteredLogs.where((log) => log.category == category).toList();
    }

    if (startDate != null) {
      filteredLogs = filteredLogs.where((log) => log.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      filteredLogs = filteredLogs.where((log) => log.timestamp.isBefore(endDate)).toList();
    }

    if (userId != null) {
      filteredLogs = filteredLogs.where((log) => log.userId == userId).toList();
    }

    // Ordenar por timestamp descendente
    filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filteredLogs.take(limit).toList();
  }

  /// Obtiene estadísticas de seguridad
  Map<String, dynamic> getSecurityStats() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final last7Days = now.subtract(const Duration(days: 7));

    final logs24h = _memoryBuffer.where((log) => log.timestamp.isAfter(last24Hours)).toList();
    final logs7d = _memoryBuffer.where((log) => log.timestamp.isAfter(last7Days)).toList();

    final criticalEvents24h = logs24h.where((log) => 
      log.level == SecurityLogLevel.critical || log.level == SecurityLogLevel.emergency
    ).length;

    final authFailures24h = logs24h.where((log) => 
      log.category == SecurityEventCategory.authentication && 
      log.event.contains('failed')
    ).length;

    final rateLimitViolations24h = logs24h.where((log) => 
      log.category == SecurityEventCategory.rateLimiting
    ).length;

    return {
      'totalEvents': _memoryBuffer.length,
      'events24h': logs24h.length,
      'events7d': logs7d.length,
      'criticalEvents24h': criticalEvents24h,
      'authFailures24h': authFailures24h,
      'rateLimitViolations24h': rateLimitViolations24h,
      'categoriesStats': _getCategoryStats(),
      'levelStats': _getLevelStats(),
      'isFileLoggingEnabled': _config.enableFileLogging,
      'isRemoteLoggingEnabled': _config.enableRemoteLogging,
      'currentLogFile': _currentLogFile?.path,
      'memoryBufferSize': _memoryBuffer.length,
    };
  }

  /// Exporta logs a archivo
  Future<File> exportLogs({
    DateTime? startDate,
    DateTime? endDate,
    List<SecurityLogLevel>? levels,
    List<SecurityEventCategory>? categories,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportFile = File('${directory.path}/security_logs_export_${DateTime.now().millisecondsSinceEpoch}.json');

    var logsToExport = List<SecurityLogEntry>.from(_memoryBuffer);

    // Aplicar filtros
    if (startDate != null) {
      logsToExport = logsToExport.where((log) => log.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      logsToExport = logsToExport.where((log) => log.timestamp.isBefore(endDate)).toList();
    }

    if (levels != null && levels.isNotEmpty) {
      logsToExport = logsToExport.where((log) => levels.contains(log.level)).toList();
    }

    if (categories != null && categories.isNotEmpty) {
      logsToExport = logsToExport.where((log) => categories.contains(log.category)).toList();
    }

    final exportData = {
      'exportTimestamp': DateTime.now().toIso8601String(),
      'totalLogs': logsToExport.length,
      'filters': {
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'levels': levels?.map((l) => l.name).toList(),
        'categories': categories?.map((c) => c.name).toList(),
      },
      'logs': logsToExport.map((log) => log.toJson()).toList(),
    };

    await exportFile.writeAsString(jsonEncode(exportData));
    Logger.info('Logs exportados a: ${exportFile.path}');
    
    return exportFile;
  }

  /// Limpia logs antiguos
  Future<void> cleanupOldLogs() async {
    final cutoffDate = DateTime.now().subtract(_config.logRetentionPeriod);
    
    _memoryBuffer.removeWhere((log) => log.timestamp.isBefore(cutoffDate));
    
    if (_config.enableFileLogging) {
      await _cleanupOldLogFiles();
    }

    Logger.info('Limpieza de logs antiguos completada');
  }

  /// Verifica la integridad de los logs
  Future<Map<String, dynamic>> verifyLogIntegrity() async {
    int totalLogs = _memoryBuffer.length;
    int corruptedLogs = 0;
    List<String> corruptedLogIds = [];

    for (final log in _memoryBuffer) {
      if (!log.verifyIntegrity()) {
        corruptedLogs++;
        corruptedLogIds.add(log.id);
      }
    }

    final result = {
      'totalLogs': totalLogs,
      'corruptedLogs': corruptedLogs,
      'integrityPercentage': totalLogs > 0 ? ((totalLogs - corruptedLogs) / totalLogs * 100) : 100.0,
      'corruptedLogIds': corruptedLogIds,
      'verificationTimestamp': DateTime.now().toIso8601String(),
    };

    if (corruptedLogs > 0) {
      await logSecurityEvent(
        level: SecurityLogLevel.critical,
        category: SecurityEventCategory.systemIntegrity,
        event: 'log_integrity_violation',
        details: result,
      );
    }

    return result;
  }

  /// Cierra el servicio y libera recursos
  Future<void> dispose() async {
    _flushTimer?.cancel();
    await _flushLogs();
    await _logStreamController.close();
    _isInitialized = false;
    Logger.info('SecurityLoggingService cerrado');
  }

  // Métodos privados

  String _generateLogId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_memoryBuffer.length}';
  }

  Future<void> _initializeFileLogging() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/security_logs');
      
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentLogFile = File('${logsDir.path}/security_log_$timestamp.json');
      
      Logger.info('Logging de archivos inicializado: ${_currentLogFile!.path}');
    } catch (e) {
      Logger.error('Error inicializando logging de archivos', e);
    }
  }

  Future<void> _flushLogs() async {
    if (!_config.enableFileLogging || _currentLogFile == null || _memoryBuffer.isEmpty) {
      return;
    }

    try {
      final logsToFlush = List<SecurityLogEntry>.from(_memoryBuffer);
      final jsonData = logsToFlush.map((log) => log.toJson()).toList();
      
      await _currentLogFile!.writeAsString(
        jsonEncode(jsonData),
        mode: FileMode.append,
      );

      // Verificar tamaño del archivo
      final fileSize = await _currentLogFile!.length();
      if (fileSize > _config.maxLogFileSize) {
        await _rotateLogFile();
      }

      Logger.debug('${logsToFlush.length} logs escritos a archivo');
    } catch (e) {
      Logger.error('Error escribiendo logs a archivo', e);
    }
  }

  Future<void> _rotateLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/security_logs');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentLogFile = File('${logsDir.path}/security_log_$timestamp.json');
      
      await _cleanupOldLogFiles();
      
      Logger.info('Archivo de log rotado: ${_currentLogFile!.path}');
    } catch (e) {
      Logger.error('Error rotando archivo de log', e);
    }
  }

  Future<void> _cleanupOldLogFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/security_logs');
      
      if (!await logsDir.exists()) return;

      final files = await logsDir.list().where((entity) => entity is File).cast<File>().toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Mantener solo los archivos más recientes
      if (files.length > _config.maxLogFiles) {
        for (int i = _config.maxLogFiles; i < files.length; i++) {
          await files[i].delete();
          Logger.debug('Archivo de log antiguo eliminado: ${files[i].path}');
        }
      }
    } catch (e) {
      Logger.error('Error limpiando archivos de log antiguos', e);
    }
  }

  Future<void> _processAlert(SecurityLogEntry logEntry) async {
    try {
      // Integrar con SecurityMonitorService para alertas
      // TODO: Implementar integración con SecurityMonitorService
      // await securityMonitor.recordEvent(
        // logEntry.event,
        // logEntry.details,
        // severity: logEntry.level.name,
      // );

      Logger.warning('Alerta de seguridad procesada: ${logEntry.event}');
    } catch (e) {
      Logger.error('Error procesando alerta de seguridad', e);
    }
  }

  Future<void> _sendToRemoteEndpoint(SecurityLogEntry logEntry) async {
    if (_config.remoteEndpoint == null) return;

    try {
      // Implementar envío a endpoint remoto
      // Esto se puede integrar con servicios como Supabase, Firebase, etc.
      Logger.debug('Log enviado a endpoint remoto: ${logEntry.id}');
    } catch (e) {
      Logger.error('Error enviando log a endpoint remoto', e);
    }
  }

  Map<String, int> _getCategoryStats() {
    final stats = <String, int>{};
    for (final category in SecurityEventCategory.values) {
      stats[category.name] = _memoryBuffer.where((log) => log.category == category).length;
    }
    return stats;
  }

  Map<String, int> _getLevelStats() {
    final stats = <String, int>{};
    for (final level in SecurityLogLevel.values) {
      stats[level.name] = _memoryBuffer.where((log) => log.level == level).length;
    }
    return stats;
  }
}