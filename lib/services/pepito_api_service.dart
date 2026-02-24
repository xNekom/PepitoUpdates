import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/pepito_activity.dart';
import '../config/api_config.dart';
import '../config/environment.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'secure_api_service.dart';

class PepitoApiService {
  static final PepitoApiService _instance = PepitoApiService._internal();
  factory PepitoApiService() => _instance;
  PepitoApiService._internal();

  late final Dio _dio;
  late final SecureApiService _secureApiService;
  bool _isInitialized = false;
  final bool _useSecureApi = true;

  /// Parsea el timestamp de la API de Pépito (formato Unix en segundos)
  DateTime _parseTimestamp(dynamic timeValue) {
    if (timeValue == null) return DateTime.now();

    if (timeValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(timeValue * 1000);
    }

    if (timeValue is String) {
      final parsed = int.tryParse(timeValue);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
      }
      return DateTime.tryParse(timeValue) ?? DateTime.now();
    }

    return DateTime.now();
  }

  /// Inicializa el servicio de API de Pépito
  void initialize() {
    if (_isInitialized) return;

    // Inicializar servicios de seguridad
    _secureApiService = SecureApiService();
    _secureApiService.initialize();

    // Configurar Dio para fallback (API directa)
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'PepitoApp/${Environment.appVersion}',
          if (ApiConfig.apiKey.isNotEmpty)
            'Authorization': 'Bearer ${ApiConfig.apiKey}',
        },
      ),
    );

    // Configuración HTTP estándar para todas las plataformas

    // Interceptor para logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => Logger.info('[API] $obj'),
      ),
    );

    // Interceptor para manejo de errores con retry
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          Logger.error('[API Error] ${error.message}');

          // Retry automático para errores de conexión
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.connectionError) {
            final requestOptions = error.requestOptions;
            final retryCount = requestOptions.extra['retryCount'] ?? 0;

            if (retryCount < ApiConfig.maxRetries) {
              Logger.info(
                '[API] Reintentando solicitud (${retryCount + 1}/${ApiConfig.maxRetries})',
              );

              // Esperar antes del retry
              await Future.delayed(ApiConfig.retryDelay);

              // Incrementar contador de reintentos
              requestOptions.extra['retryCount'] = retryCount + 1;

              try {
                final response = await _dio.fetch(requestOptions);
                handler.resolve(response);
                return;
              } catch (e) {
                Logger.error('[API] Reintento fallido: $e');
              }
            } else {
              Logger.error(
                '[API] Máximo de reintentos alcanzado, propagando error para fallback',
              );
            }
          }

          handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  /// Obtiene el estado actual de Pépito
  Future<PepitoStatus> getCurrentStatus() async {
    if (!_isInitialized) {
      throw Exception(
        'PepitoApiService no ha sido inicializado. Llame a initialize() primero.',
      );
    }

    // Priorizar Edge Functions si están configuradas
    if (ApiConfig.useEdgeFunctions) {
      try {
        Logger.info(
          '[API] Obteniendo estado a través de Edge Function (método principal)',
        );
        final activity = await _secureApiService.getCurrentStatus();

        if (activity != null) {
          Logger.info(
            '[API] Estado obtenido exitosamente a través de Edge Function',
          );
          return PepitoStatus(
            event: activity.event,
            type: activity.type,
            timestamp: activity.timestamp,
            img: activity.img ?? '',
            cached: activity.cached,
            authenticated: activity.authenticated,
          );
        }
      } catch (e) {
        Logger.warning(
          '[API] Error con Edge Function, usando fallback a API directa: $e',
        );
        // En desarrollo/debug, permitir siempre fallback a API directa
        // En producción, solo permitir si no estamos en web
        if (!kDebugMode && kIsWeb) {
          Logger.warning(
            '[API] En web producción, no se hace fallback a API directa por restricciones de CORS',
          );
          throw Exception(
            'Error obteniendo estado: Las Edge Functions no están disponibles y la API directa no es compatible con web por restricciones de CORS.\n\nPara desarrollo web:\n• flutter run -d chrome (funciona en debug)\n• run_with_local_proxy.bat (recomendado)\n• run_with_cors_disabled.bat\n\nPara móvil/desktop: Funciona automáticamente.',
          );
        }
        // En desarrollo o móvil/desktop, permitir fallback
      }
    }

    // Fallback a API directa solo si Edge Functions no están disponibles o fallan
    if (ApiConfig.isConfigured) {
      Logger.info('[API] Usando API directa como fallback');
      return await _getStatusDirectly();
    }

    throw Exception(
      'No hay configuración válida disponible. Configure Edge Functions o API directa.',
    );
  }

  /// Obtiene el estado directamente de la API de Pépito
  Future<PepitoStatus> _getStatusDirectly() async {
    try {
      Logger.info('[API] Obteniendo estado directamente de la API');

      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.statusEndpoint}',
        options: Options(
          headers: {
            ...ApiConfig.defaultHeaders,
            if (ApiConfig.apiKey.isNotEmpty) 'X-API-Key': ApiConfig.apiKey,
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        Logger.info('[API] Estado obtenido exitosamente de la API directa');

        return PepitoStatus(
          event: data['event'] ?? 'Desconocido',
          type: data['type'] ?? 'unknown',
          timestamp: _parseTimestamp(
            data['time'],
          ), // Cambiado 'timestamp' por 'time'
          img: data['img'] ?? '',
          cached: false,
          authenticated: false,
        );
      } else {
        throw Exception(
          'Respuesta inválida del servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error('[API] Error obteniendo estado directamente: $e');
      rethrow;
    }
  }

  Future<List<PepitoActivity>> getActivities({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'PepitoApiService no ha sido inicializado. Llame a initialize() primero.',
      );
    }

    // En desarrollo web, saltar directamente a API directa
    if (kIsWeb && kDebugMode) {
      Logger.info(
        '[API] Desarrollo web: saltando Edge Functions, usando API directa',
      );
    } else if (ApiConfig.useEdgeFunctions) {
      try {
        Logger.info(
          '[API] Obteniendo actividades a través de Edge Function (método principal)',
        );
        final activity = await _secureApiService.getCurrentStatus();

        if (activity != null) {
          // Verificar si está en el rango de fechas
          bool isInRange = true;
          if (startDate != null && activity.timestamp.isBefore(startDate)) {
            isInRange = false;
          }
          if (endDate != null && activity.timestamp.isAfter(endDate)) {
            isInRange = false;
          }

          final activities = isInRange ? [activity] : <PepitoActivity>[];

          // Aplicar offset y limit
          final startIndex = offset;
          final endIndex = (startIndex + limit).clamp(0, activities.length);
          final paginatedActivities = startIndex < activities.length
              ? activities.sublist(startIndex, endIndex)
              : <PepitoActivity>[];

          Logger.info(
            '[API] Devolviendo ${paginatedActivities.length} actividad(es) a través de Edge Function',
          );
          return paginatedActivities;
        }
      } catch (e) {
        Logger.warning(
          '[API] Error con Edge Function para actividades, usando fallback a API directa: $e',
        );
        // En desarrollo/debug, permitir siempre fallback a API directa
        // En producción, solo permitir si no estamos en web
        if (!kDebugMode && kIsWeb) {
          Logger.warning(
            '[API] En web producción, no se hace fallback a API directa por restricciones de CORS',
          );
          throw Exception(
            'Error obteniendo actividades: Las Edge Functions no están disponibles y la API directa no es compatible con web por restricciones de CORS.\n\nSoluciones:\n• Use run_with_local_proxy.bat (recomendado)\n• Use run_with_cors_disabled.bat\n• Use móvil/desktop para desarrollo\n\nPara producción: Configure CORS en el servidor API o use solo Edge Functions.',
          );
        }
        // En desarrollo o móvil/desktop, permitir fallback
      }
    }

    // Fallback a API directa solo si Edge Functions no están disponibles o fallan
    if (ApiConfig.isConfigured) {
      Logger.info('[API] Usando API directa como fallback para actividades');
      return await _getActivitiesDirectly(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
    }

    throw Exception(
      'No hay configuración válida disponible. Configure Edge Functions o API directa.',
    );
  }

  Future<List<PepitoActivity>> _getActivitiesDirectly({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      Logger.info('[API] Obteniendo actividades directamente de la API');
      Logger.info(
        '[API] Nota: La API de Pépito solo tiene /last-status, simulando actividades basadas en estado actual',
      );

      // Obtener el estado actual
      final response = await _dio.get(
        ApiConfig.statusEndpoint,
        options: Options(
          headers: {
            ...ApiConfig.defaultHeaders,
            if (ApiConfig.apiKey.isNotEmpty) 'X-API-Key': ApiConfig.apiKey,
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Crear una actividad basada en el estado actual
        final activity = PepitoActivity(
          id:
              data['time']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          event: data['event'] ?? 'pepito',
          type: data['type'] ?? 'unknown',
          timestamp: _parseTimestamp(data['time']),
          img: data['img'] ?? '',
          source: 'api_direct',
          cached: false,
          authenticated: false,
        );

        // Verificar si está en el rango de fechas solicitado
        bool isInRange = true;
        if (startDate != null && activity.timestamp.isBefore(startDate)) {
          isInRange = false;
        }
        if (endDate != null && activity.timestamp.isAfter(endDate)) {
          isInRange = false;
        }

        final activities = isInRange ? [activity] : <PepitoActivity>[];

        // Aplicar offset y limit
        final startIndex = offset;
        final endIndex = (startIndex + limit).clamp(0, activities.length);
        final paginatedActivities = startIndex < activities.length
            ? activities.sublist(startIndex, endIndex)
            : <PepitoActivity>[];

        Logger.info(
          '[API] ${paginatedActivities.length} actividad(es) simulada(s) desde estado actual',
        );
        return paginatedActivities;
      } else {
        throw Exception(
          'Respuesta inválida del servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error('[API] Error obteniendo actividades directamente: $e');
      rethrow;
    }
  }

  Future<List<PepitoActivity>> getTodayActivities() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getActivities(startDate: startOfDay, endDate: endOfDay);
  }

  Future<Map<String, dynamic>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'PepitoApiService no ha sido inicializado. Llame a initialize() primero.',
      );
    }

    try {
      final activities = await getActivities(
        startDate: startDate,
        endDate: endDate,
        limit: 1000, // Obtener más actividades para estadísticas
      );

      // Calcular estadísticas básicas
      final stats = <String, dynamic>{
        'total_activities': activities.length,
        'unique_events': activities.map((a) => a.event).toSet().length,
        'unique_types': activities.map((a) => a.type).toSet().length,
        'date_range': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
        'security_info': {
          'using_secure_api':
              _useSecureApi && Environment.enableSecurityFeatures,
          'authenticated': activities.any((a) => a.authenticated),
          'cached_data': activities.any((a) => a.cached),
          'sources': activities.map((a) => a.source).toSet().toList(),
        },
      };

      // Estadísticas por evento
      final eventCounts = <String, int>{};
      for (final activity in activities) {
        eventCounts[activity.event] = (eventCounts[activity.event] ?? 0) + 1;
      }
      stats['events'] = eventCounts;

      // Estadísticas por tipo
      final typeCounts = <String, int>{};
      for (final activity in activities) {
        typeCounts[activity.type] = (typeCounts[activity.type] ?? 0) + 1;
      }
      stats['types'] = typeCounts;

      // Estadísticas de confiabilidad
      if (activities.isNotEmpty) {
        final validConfidences = activities
            .where((a) => a.confidence != null)
            .map((a) => a.confidence!);
        final avgConfidence = validConfidences.isNotEmpty
            ? validConfidences.reduce((a, b) => a + b) / validConfidences.length
            : 0.0;
        final recentActivities = activities.where((a) => a.isRecent).length;
        final reliableActivities = activities.where((a) => a.isReliable).length;

        stats['reliability'] = {
          'average_confidence': avgConfidence,
          'recent_activities': recentActivities,
          'reliable_activities': reliableActivities,
          'reliability_percentage':
              (reliableActivities / activities.length * 100).round(),
        };
      }

      Logger.info(
        '[API] Estadísticas calculadas para ${activities.length} actividades',
      );
      return stats;
    } catch (e) {
      Logger.error('[API] Error al calcular estadísticas: $e');
      throw Exception('Error al calcular estadísticas: $e');
    }
  }

  Future<bool> registerForNotifications(String fcmToken) async {
    try {
      // La API de Pépito no tiene endpoint de notificaciones,
      // simulamos el registro exitoso
      Logger.info(
        '[API] Simulando registro de notificaciones (API real no soporta notificaciones)',
      );
      return true;
    } catch (e) {
      Logger.error('[API] Error al registrar notificaciones: $e');
      rethrow;
    }
  }

  Future<bool> unregisterFromNotifications(String fcmToken) async {
    try {
      // La API de Pépito no tiene endpoint de notificaciones,
      // simulamos la desregistración exitosa
      Logger.info(
        '[API] Simulando desregistro de notificaciones (API real no soporta notificaciones)',
      );
      return true;
    } catch (e) {
      Logger.error('[API] Error al desregistrar notificaciones: \$e');
      rethrow;
    }
  }

  /// Descarga y procesa una imagen desde una URL
  Future<Uint8List?> _downloadImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        Logger.warning('[API] URL de imagen vacía, saltando descarga');
        return null;
      }

      Logger.info('[API] Descargando imagen desde: \$imageUrl');

      final response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            ...ApiConfig.defaultHeaders,
            if (ApiConfig.apiKey.isNotEmpty) 'X-API-Key': ApiConfig.apiKey,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final imageData = response.data as Uint8List;
        Logger.info(
          '[API] Imagen descargada exitosamente (\${imageData.length} bytes)',
        );
        return imageData;
      } else {
        Logger.warning(
          '[API] Error descargando imagen: código \${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      Logger.error('[API] Error descargando imagen: \$e');
      return null;
    }
  }

  /// Almacena una imagen en Supabase Storage y devuelve la URL pública
  Future<String?> _storeImageInSupabase(
    Uint8List imageData,
    String fileName,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      // Crear nombre de archivo único con timestamp
      final uniqueFileName =
          '\${DateTime.now().millisecondsSinceEpoch}_\$fileName';
      final storagePath = '\${SupabaseConfig.imagesBucket}/\$uniqueFileName';

      Logger.info('[API] Almacenando imagen en Supabase: \$storagePath');

      // Subir imagen a Supabase Storage
      await supabase.storage
          .from(SupabaseConfig.imagesBucket)
          .uploadBinary(storagePath, imageData);

      // Obtener URL pública de la imagen
      final publicUrl = supabase.storage
          .from(SupabaseConfig.imagesBucket)
          .getPublicUrl(storagePath);

      Logger.info(
        '[API] Imagen almacenada exitosamente en Supabase: \$publicUrl',
      );
      return publicUrl;
    } catch (e) {
      Logger.error('[API] Error almacenando imagen en Supabase: \$e');
      return null;
    }
  }

  /// Procesa y almacena una imagen desde la respuesta de la API
  Future<String?> _processApiImage(
    String imageUrl,
    String activityType,
    DateTime timestamp,
  ) async {
    try {
      // Descargar imagen
      final imageData = await _downloadImage(imageUrl);
      if (imageData == null) {
        return null;
      }

      // Crear nombre de archivo descriptivo
      final fileName =
          '\${activityType}_\${timestamp.millisecondsSinceEpoch}.jpg';

      // Almacenar en Supabase
      final storedImageUrl = await _storeImageInSupabase(imageData, fileName);

      return storedImageUrl;
    } catch (e) {
      Logger.error('[API] Error procesando imagen de API: \$e');
      return null;
    }
  }

  /// Procesa una actividad con imagen y actualiza la URL de la imagen
  Future<PepitoActivity> _processActivityWithImage(
    PepitoActivity activity,
  ) async {
    try {
      // Si ya tiene imageUrl o img está vacío, no procesar
      if (activity.imageUrl != null && activity.imageUrl!.isNotEmpty) {
        Logger.info(
          '[API] Actividad ya tiene imageUrl, saltando procesamiento: \${activity.imageUrl}',
        );
        return activity;
      }

      if (activity.img == null || activity.img!.isEmpty) {
        Logger.info(
          '[API] Actividad sin imagen (img vacío), saltando procesamiento',
        );
        return activity;
      }

      Logger.info(
        '[API] Procesando imagen para actividad: \${activity.event} (\${activity.timestamp})',
      );

      // Procesar imagen
      final processedImageUrl = await _processApiImage(
        activity.img!,
        activity.type,
        activity.timestamp,
      );

      if (processedImageUrl != null) {
        // Crear nueva actividad con la URL procesada
        return PepitoActivity(
          id: activity.id,
          event: activity.event,
          type: activity.type,
          timestamp: activity.timestamp,
          img: activity.img, // Mantener el img original
          imageUrl: processedImageUrl, // Nueva URL de Supabase
          location: activity.location,
          confidence: activity.confidence,
          metadata: {
            ...activity.metadata ?? {},
            'image_processed_at': DateTime.now().toIso8601String(),
            'original_image_url': activity.img,
          },
          source: activity.source,
          cached: activity.cached,
          authenticated: activity.authenticated,
          createdAt: activity.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      return activity;
    } catch (e) {
      Logger.error('[API] Error procesando actividad con imagen: \$e');
      return activity; // Devolver actividad original en caso de error
    }
  }
}
