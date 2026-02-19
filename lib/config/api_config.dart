import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// Configuración de la API
class ApiConfig {
  // URL base de la API obtenida de variables de entorno (fallback)
  static String get baseUrl {
    // En desarrollo web, usar proxy local para evitar CORS
    if (kIsWeb && kDebugMode) {
      return 'http://localhost:3001/api/thecatdoor';
    }
    return EnvironmentConfig.pepitoApiUrl;
  }

  // Clave de API obtenida de variables de entorno
  static String get apiKey => EnvironmentConfig.supabaseAnonKey;
  
  // Configuración de Supabase
  static String get supabaseUrl {
    // En desarrollo web, usar proxy local para evitar CORS
    if (kIsWeb && kDebugMode) {
      return 'http://localhost:3001/api/supabase';
    }
    return EnvironmentConfig.supabaseUrl;
  }
  static String get supabaseAnonKey => EnvironmentConfig.supabaseAnonKey;

  // Edge Functions URLs (PRINCIPAL)
  static String get edgeFunctionBaseUrl => EnvironmentConfig.supabaseUrl;
  static String get pepitoProxyUrl => '$edgeFunctionBaseUrl/functions/v1/pepito-proxy';
  static String get statusEndpointEdge => '$pepitoProxyUrl/status';
  static String get activitiesEndpointEdge => '$pepitoProxyUrl/activities';
  static String get healthEndpointEdge => '$pepitoProxyUrl/health';
  
  // Endpoints específicos de la API de Pépito (FALLBACK)
  static const String statusEndpoint = '/rest/v1/last-status';
  static const String sseEndpoint = '/sse/v1/events';
  // Nota: La API de Pépito solo tiene estos dos endpoints disponibles
  // Los siguientes endpoints no existen en la API real:
  // static const String activitiesEndpoint = '/activities';
  // static const String statisticsEndpoint = '/statistics';
  // static const String notificationsEndpoint = '/notifications';
  
  // Configuración de timeouts
  static Duration get connectionTimeout => EnvironmentConfig.connectionTimeout;
  static Duration get receiveTimeout => EnvironmentConfig.receiveTimeout;
  static const Duration sendTimeout = Duration(seconds: 5);
  
  // Configuración de paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Configuración de cache
  static Duration get cacheExpiration => EnvironmentConfig.cacheTimeout;
  
  // Configuración de retry
  static int get maxRetries => EnvironmentConfig.maxRetries;
  static Duration get retryDelay => EnvironmentConfig.retryDelay;
  
  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'PepitoUpdates/1.0.0',
  };
  
  // Headers para Edge Functions
  static Map<String, String> get edgeFunctionHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'PepitoUpdates/1.0.0',
    'Authorization': 'Bearer $supabaseAnonKey',
    'apikey': supabaseAnonKey,
  };
  
  // Validar configuración de API directa
  static bool get isConfigured {
    return baseUrl.isNotEmpty && 
           baseUrl != 'YOUR_API_BASE_URL' &&
           apiKey.isNotEmpty &&
           apiKey != 'YOUR_API_KEY';
  }
  
  // Validar configuración de Edge Functions
  static bool get isEdgeFunctionConfigured {
    return edgeFunctionBaseUrl.isNotEmpty && 
           !edgeFunctionBaseUrl.contains('your-project') &&
           supabaseAnonKey.isNotEmpty &&
           supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
  }
  
  // Determinar si usar Edge Functions como principal
  static bool get useEdgeFunctions {
    // En web de producción, forzar Edge Functions para evitar CORS contra api.thecatdoor.com
    if (kIsWeb) {
      if (kDebugMode) return false;
      return isEdgeFunctionConfigured;
    }
    return isEdgeFunctionConfigured && !EnvironmentConfig.isDevelopment;
  }
  
  // Obtener endpoint de estado preferido
  static String get preferredStatusEndpoint {
    return useEdgeFunctions ? statusEndpointEdge : '$baseUrl$statusEndpoint';
  }
  
  // Obtener headers preferidos
  static Map<String, String> get preferredHeaders {
    return useEdgeFunctions ? edgeFunctionHeaders : defaultHeaders;
  }
  
  // Estado de configuración
  static String get configurationStatus {
    if (useEdgeFunctions) {
      return 'Usando Edge Functions (Recomendado)';
    } else if (isEdgeFunctionConfigured) {
      return 'Edge Functions disponibles pero características de seguridad deshabilitadas';
    } else if (isConfigured) {
      return 'Usando API directa (Fallback)';
    } else {
      return 'ERROR: Ninguna configuración válida encontrada';
    }
  }
}