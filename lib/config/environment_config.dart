import 'environment.dart';

enum AppEnvironment { dev, qa, uat, pro }

class EnvironmentConfig {
  EnvironmentConfig._();

  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  static AppEnvironment get currentEnvironment {
    switch (_environment) {
      case 'qa': return AppEnvironment.qa;
      case 'uat': return AppEnvironment.uat;
      case 'pro': return AppEnvironment.pro;
      default: return AppEnvironment.dev;
    }
  }

  static bool get isProduction => currentEnvironment == AppEnvironment.pro;
  static bool get isDevelopment => currentEnvironment == AppEnvironment.dev;

  static String get supabaseUrl => Environment.supabaseUrl;
  static String get supabaseAnonKey => Environment.supabaseAnonKey;

  static bool get enableLogging => !isProduction;

  static Duration get pollingInterval {
    switch (currentEnvironment) {
      case AppEnvironment.pro: return const Duration(minutes: 5);
      case AppEnvironment.uat: case AppEnvironment.qa: return const Duration(minutes: 2);
      case AppEnvironment.dev: return const Duration(minutes: 1);
    }
  }

  static Duration get connectionTimeout {
    switch (currentEnvironment) {
      case AppEnvironment.pro: return const Duration(seconds: 30);
      case AppEnvironment.uat: case AppEnvironment.qa: return const Duration(seconds: 20);
      case AppEnvironment.dev: return const Duration(seconds: 10);
    }
  }

  static Duration get receiveTimeout {
    switch (currentEnvironment) {
      case AppEnvironment.pro: return const Duration(seconds: 30);
      case AppEnvironment.uat: case AppEnvironment.qa: return const Duration(seconds: 20);
      case AppEnvironment.dev: return const Duration(seconds: 10);
    }
  }

  static String get environmentName {
    switch (currentEnvironment) {
      case AppEnvironment.pro: return 'production';
      case AppEnvironment.uat: return 'uat';
      case AppEnvironment.qa: return 'qa';
      case AppEnvironment.dev: return 'dev';
    }
  }
}
