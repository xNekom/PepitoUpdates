import 'package:dio/dio.dart';
import '../models/pepito_activity.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

class PepitoApiService {
  static final PepitoApiService _instance = PepitoApiService._internal();
  factory PepitoApiService() => _instance;
  PepitoApiService._internal();

  late final Dio _dio;
  bool _isInitialized = false;

  DateTime _parseTimestamp(dynamic timeValue) {
    if (timeValue == null) return DateTime.now();
    if (timeValue is int) return DateTime.fromMillisecondsSinceEpoch(timeValue * 1000);
    if (timeValue is String) {
      final parsed = int.tryParse(timeValue);
      if (parsed != null) return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
      return DateTime.tryParse(timeValue) ?? DateTime.now();
    }
    return DateTime.now();
  }

  void initialize() {
    if (_isInitialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.preferredStatusEndpoint,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.preferredHeaders,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        Logger.error('[API] ${error.message}');
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError) {
          final opts = error.requestOptions;
          final retryCount = (opts.extra['retryCount'] as int?) ?? 0;
          if (retryCount < 3) {
            await Future.delayed(const Duration(seconds: 2));
            opts.extra['retryCount'] = retryCount + 1;
            try {
              final response = await _dio.fetch(opts);
              handler.resolve(response);
              return;
            } catch (_) {}
          }
        }
        handler.next(error);
      },
    ));

    _isInitialized = true;
  }

  Future<PepitoStatus> getCurrentStatus() async {
    if (!_isInitialized) initialize();
    try {
      Logger.info('[API] Obteniendo estado');
      final response = await _dio.get('');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return PepitoStatus(
          event: data['event'] ?? 'Desconocido',
          type: data['type'] ?? 'unknown',
          timestamp: _parseTimestamp(data['time'] ?? data['timestamp']),
          img: data['img'] ?? '',
          cached: data['cached'] ?? false,
          authenticated: data['authenticated'] ?? false,
        );
      }
      throw Exception('Respuesta inválida: ${response.statusCode}');
    } catch (e) {
      Logger.error('[API] Error obteniendo estado: $e');
      rethrow;
    }
  }

  Future<List<PepitoActivity>> getActivities({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) initialize();
    try {
      final response = await _dio.get(
        ApiConfig.activitiesEndpoint,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['activities'] as List<dynamic>? ?? []);
        var activities = data.map((item) => PepitoActivity(
          id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          event: item['event'] ?? 'pepito',
          type: item['type'] ?? 'unknown',
          timestamp: _parseTimestamp(item['timestamp'] ?? item['time']),
          img: item['img'] ?? '',
          source: 'api',
          cached: item['cached'] ?? false,
          authenticated: item['authenticated'] ?? false,
        )).toList();

        if (startDate != null) activities = activities.where((a) => !a.timestamp.isBefore(startDate)).toList();
        if (endDate != null) activities = activities.where((a) => !a.timestamp.isAfter(endDate)).toList();

        return activities;
      }
      return [];
    } catch (e) {
      Logger.error('[API] Error obteniendo actividades: $e');
      return [];
    }
  }

  Future<List<PepitoActivity>> getTodayActivities() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getActivities(startDate: startOfDay, limit: 100);
  }

  Future<Map<String, dynamic>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final activities = await getActivities(
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );

      return {
        'total_activities': activities.length,
        'unique_events': activities.map((a) => a.event).toSet().length,
        'unique_types': activities.map((a) => a.type).toSet().length,
        'date_range': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
      };
    } catch (e) {
      Logger.error('[API] Error al calcular estadísticas: $e');
      rethrow;
    }
  }
}
