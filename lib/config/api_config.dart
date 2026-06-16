import 'package:flutter/foundation.dart';
import 'environment_config.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb && kDebugMode) {
      return 'http://localhost:3001/api/thecatdoor';
    }
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.thecatdoor.com',
    );
    return apiBaseUrl;
  }

  static String get supabaseUrl {
    if (kIsWeb && kDebugMode) {
      return 'http://localhost:3001/api/supabase';
    }
    return EnvironmentConfig.supabaseUrl;
  }

  static String get supabaseAnonKey => EnvironmentConfig.supabaseAnonKey;

  static String get pepitoProxyUrl => '${EnvironmentConfig.supabaseUrl}/functions/v1/pepito-proxy';
  static String get preferredStatusEndpoint => '$pepitoProxyUrl/status';
  static String get activitiesEndpoint => '$pepitoProxyUrl/activities';
  static String get healthEndpoint => '$pepitoProxyUrl/health';

  static const String statusEndpoint = '/rest/v1/last-status';

  static Duration get connectionTimeout => EnvironmentConfig.connectionTimeout;
  static Duration get receiveTimeout => EnvironmentConfig.receiveTimeout;
  static const Duration sendTimeout = Duration(seconds: 5);
  static const int defaultPageSize = 20;

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (!kIsWeb) 'User-Agent': 'PepitoUpdates/1.0.0',
    'Authorization': 'Bearer $supabaseAnonKey',
    'apikey': supabaseAnonKey,
  };

  static Map<String, String> get edgeFunctionHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (!kIsWeb) 'User-Agent': 'PepitoUpdates/1.0.0',
    'Authorization': 'Bearer $supabaseAnonKey',
    'apikey': supabaseAnonKey,
  };

  static Map<String, String> get preferredHeaders => edgeFunctionHeaders;
}