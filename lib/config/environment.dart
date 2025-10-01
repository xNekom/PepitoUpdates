import 'package:flutter/foundation.dart';

/// Configuración de entorno para la aplicación
/// Las variables de entorno deben configurarse antes del despliegue
class Environment {
  // Variables de entorno que deben ser configuradas externamente
  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ewxarmlqoowlxdqoebcb.supabase.co',
  );
  
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3eGFybWxxb293bHhkcW9lYmNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3Mjc0NDksImV4cCI6MjA3MDMwMzQ0OX0.WnAVs80JTH9zZvzI4TV0zsXJVEz0eDn81nfM2UPVJug',
  );
  
  static const String _apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: kDebugMode ? 'demo-api-key-for-development-only' : '',
  );
  
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.thecatdoor.com', // API real de Pépito
  );
  
  static const String _edgeFunctionUrl = String.fromEnvironment(
    'EDGE_FUNCTION_URL',
    defaultValue: 'https://ewxarmlqoowlxdqoebcb.supabase.co/functions/v1',
  );
  
  static const String _appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  
  static const bool _enableSecurityFeatures = bool.fromEnvironment(
    'ENABLE_SECURITY_FEATURES',
    defaultValue: true,
  );
  
  static const int _rateLimitPerMinute = int.fromEnvironment(
    'RATE_LIMIT_PER_MINUTE',
    defaultValue: 60,
  );
  
  static const int _cacheTimeoutSeconds = int.fromEnvironment(
    'CACHE_TIMEOUT_SECONDS',
    defaultValue: 30,
  );

  // Getters públicos
  static String get supabaseUrl {
    if (kDebugMode) {
      // En modo debug, usar valores por defecto sin validación estricta
      return _supabaseUrl;
    }
    
    if (_supabaseUrl.isEmpty || _supabaseUrl.contains('your-project')) {
      throw Exception(
        'SUPABASE_URL no está configurada. '
        'Configure las variables de entorno antes del despliegue.'
      );
    }
    return _supabaseUrl;
  }
  
  static String get supabaseAnonKey {
    if (kDebugMode) {
      // En modo debug, usar valores por defecto sin validación estricta
      return _supabaseAnonKey;
    }
    
    if (_supabaseAnonKey.isEmpty || _supabaseAnonKey.contains('your-anon-key')) {
      throw Exception(
        'SUPABASE_ANON_KEY no está configurada. '
        'Configure las variables de entorno antes del despliegue.'
      );
    }
    return _supabaseAnonKey;
  }
  
  static String get apiKey {
    if (kDebugMode) {
      // En modo debug, usar valores por defecto sin validación estricta
      return _apiKey;
    }
    
    if (_apiKey.isEmpty || _apiKey.contains('your-api-key')) {
      throw Exception(
        'API_KEY no está configurada. '
        'Configure las variables de entorno antes del despliegue.'
      );
    }
    return _apiKey;
  }
  
  static String get apiBaseUrl {
    if (kDebugMode) {
      // En modo debug, usar valores por defecto sin validación estricta
      return _apiBaseUrl;
    }
    
    if (_apiBaseUrl.isEmpty || _apiBaseUrl.contains('example.com')) {
      throw Exception(
        'API_BASE_URL no está configurada. '
        'Configure las variables de entorno antes del despliegue.'
      );
    }
    return _apiBaseUrl;
  }
  
  static String get edgeFunctionUrl {
    if (kDebugMode) {
      return _edgeFunctionUrl;
    }
    
    if (_edgeFunctionUrl.isEmpty || _edgeFunctionUrl.contains('your-project')) {
      throw Exception(
        'EDGE_FUNCTION_URL no está configurada. '
        'Configure las variables de entorno antes del despliegue.'
      );
    }
    return _edgeFunctionUrl;
  }
  
  static String get appVersion => _appVersion;
  
  static bool get enableSecurityFeatures => _enableSecurityFeatures;
  
  static int get rateLimitPerMinute => _rateLimitPerMinute;
  
  static int get cacheTimeoutSeconds => _cacheTimeoutSeconds;
  
  static Duration get cacheTimeout => Duration(seconds: _cacheTimeoutSeconds);
  
  /// URL completa para el proxy de Pépito
  static String get pepitoProxyUrl => '$edgeFunctionUrl/pepito-proxy';
  
  /// URL para el endpoint de estado
  static String get pepitoStatusUrl => '$pepitoProxyUrl/status';
  
  /// URL para el endpoint de salud
  static String get pepitoHealthUrl => '$pepitoProxyUrl/health';
  
  // Validación de configuración
  static bool get isConfigured {
    try {
      supabaseUrl;
      supabaseAnonKey;
      apiKey;
      apiBaseUrl;
      edgeFunctionUrl;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static String get configurationStatus {
    if (kDebugMode) {
      return 'Modo desarrollo - usando valores por defecto';
    }
    
    if (!isConfigured) {
      return 'ERROR: Variables de entorno no configuradas para producción';
    }
    
    return 'Configuración de producción válida';
  }
  
  /// Obtiene un resumen de la configuración actual
  static Map<String, dynamic> get configSummary {
    return {
      'app_version': appVersion,
      'environment': kDebugMode ? 'development' : 'production',
      'security_features_enabled': enableSecurityFeatures,
      'rate_limit_per_minute': rateLimitPerMinute,
      'cache_timeout_seconds': cacheTimeoutSeconds,
      'supabase_configured': _supabaseUrl.isNotEmpty,
      'edge_functions_configured': _edgeFunctionUrl.isNotEmpty,
      'api_configured': _apiBaseUrl.isNotEmpty,
    };
  }
}