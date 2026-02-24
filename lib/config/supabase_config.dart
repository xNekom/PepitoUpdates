import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// Configuración de Supabase
class SupabaseConfig {
  // Credenciales obtenidas de variables de entorno
  static String get supabaseUrl => EnvironmentConfig.supabaseUrl;
  static String get supabaseAnonKey => EnvironmentConfig.supabaseAnonKey;
  
  // Configuración de Edge Functions
  static String get edgeFunctionUrl => '${EnvironmentConfig.supabaseUrl}/functions/v1';
  
  // Configuración de la tabla principal
  static const String activitiesTable = 'pepito_activities';
  static const String usersTable = 'users';
  static const String sessionsTable = 'user_sessions';
  static const String auditLogsTable = 'audit_logs';
  
  // Configuración de Storage
  static const String imagesBucket = 'pepito_images';
  
  // Configuración de Edge Functions
  static const String pepitoProxyFunction = 'pepito-proxy';
  static const String authFunction = 'auth-handler';
  static const String securityFunction = 'security-middleware';
  
  // Configuración de timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration edgeFunctionTimeout = Duration(seconds: 15);
  
  // Configuración de paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Configuración de cache
  static const Duration cacheExpiration = Duration(minutes: 5);
  static Duration get cacheTimeout => EnvironmentConfig.cacheTimeout;
  
  // Configuración de limpieza automática
  static const int daysToKeepActivities = 30;
  static const int daysToKeepAuditLogs = 90;
  
  // Configuración de realtime
  static const String realtimeChannel = 'pepito_activities_channel';
  static const String securityChannel = 'security_events_channel';
  
  // Configuración de seguridad
  static bool get enableSecurityFeatures => !EnvironmentConfig.isDevelopment;
  static int get rateLimitPerMinute => EnvironmentConfig.rateLimitRequests;
  
  // Configuración de logs
  static bool get enableLogs => kDebugMode;
  static bool get enableSecurityLogs => enableSecurityFeatures;
  
  // Versión de la aplicación
  static const String appVersion = '1.0.0';
  
  // Headers de seguridad
  static Map<String, String> get securityHeaders => {
    'X-App-Version': appVersion,
    'X-Client-Type': 'flutter',
    'X-Security-Level': enableSecurityFeatures ? 'high' : 'standard',
  };
  
  // Validar configuración
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' && 
           supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
           supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty;
  }
  
  // Validar configuración de Edge Functions
  static bool get isEdgeFunctionConfigured {
    return edgeFunctionUrl.isNotEmpty && 
           edgeFunctionUrl != 'YOUR_EDGE_FUNCTION_URL';
  }
  
  // Obtener configuración de estado
  static String get configurationStatus {
    if (isConfigured && isEdgeFunctionConfigured) {
      return 'Supabase y Edge Functions configurados correctamente';
    } else if (isConfigured) {
      return 'Supabase configurado, Edge Functions requieren configuración';
    } else {
      return 'Supabase requiere configuración: actualizar URL y clave anónima';
    }
  }
  
  // Obtener resumen de configuración
  static Map<String, dynamic> get configSummary => {
    'supabase_configured': isConfigured,
    'edge_functions_configured': isEdgeFunctionConfigured,
    'security_enabled': enableSecurityFeatures,
    'rate_limit': rateLimitPerMinute,
    'cache_timeout': cacheTimeout.inSeconds,
    'app_version': appVersion,
  };
}