/// Configuración de entornos para la aplicación
enum AppEnvironment {
  dev,
  qa,
  uat,
  pro,
}

class EnvironmentConfig {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  static AppEnvironment get currentEnvironment {
    switch (_environment) {
      case 'qa':
        return AppEnvironment.qa;
      case 'uat':
        return AppEnvironment.uat;
      case 'pro':
        return AppEnvironment.pro;
      case 'dev':
      default:
        return AppEnvironment.dev;
    }
  }

  static bool get isProduction => currentEnvironment == AppEnvironment.pro;
  static bool get isDevelopment => currentEnvironment == AppEnvironment.dev;
  static bool get isQA => currentEnvironment == AppEnvironment.qa;
  static bool get isUAT => currentEnvironment == AppEnvironment.uat;
  static bool get isDebug => _environment == 'debug';

  // URLs de API según el entorno
  static String get pepitoApiUrl {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return 'https://api.thecatdoor.com';
      case AppEnvironment.uat:
        return 'https://api.thecatdoor.com';
      case AppEnvironment.qa:
        return 'https://api.thecatdoor.com';
      case AppEnvironment.dev:
        return 'https://api.thecatdoor.com';  // URL real de la API de Pépito
    }
  }

  // URLs de Supabase según el entorno
  static String get supabaseUrl {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return 'https://ewxarmlqoowlxdqoebcb.supabase.co';
      case AppEnvironment.uat:
        return 'https://ewxarmlqoowlxdqoebcb.supabase.co';
      case AppEnvironment.qa:
        return 'https://ewxarmlqoowlxdqoebcb.supabase.co';
      case AppEnvironment.dev:
        return 'https://ewxarmlqoowlxdqoebcb.supabase.co';  // Tu proyecto real
    }
  }

  // Anon key de Supabase según el entorno
  static String get supabaseAnonKey {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_PRO', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3eGFybWxxb293bHhkcW9lYmNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3Mjc0NDksImV4cCI6MjA3MDMwMzQ0OX0.WnAVs80JTH9zZvzI4TV0zsXJVEz0eDn81nfM2UPVJug');
      case AppEnvironment.uat:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_UAT', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3eGFybWxxb293bHhkcW9lYmNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3Mjc0NDksImV4cCI6MjA3MDMwMzQ0OX0.WnAVs80JTH9zZvzI4TV0zsXJVEz0eDn81nfM2UPVJug');
      case AppEnvironment.qa:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_QA', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3eGFybWxxb293bHhkcW9lYmNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3Mjc0NDksImV4cCI6MjA3MDMwMzQ0OX0.WnAVs80JTH9zZvzI4TV0zsXJVEz0eDn81nfM2UPVJug');
      case AppEnvironment.dev:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_DEV', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3eGFybWxxb293bHhkcW9lYmNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3Mjc0NDksImV4cCI6MjA3MDMwMzQ0OX0.WnAVs80JTH9zZvzI4TV0zsXJVEz0eDn81nfM2UPVJug');
    }
  }

  // Configuración de logging
  static bool get enableLogging => !isProduction;

  // Configuración de debug
  static bool get enableDebugMode => isDevelopment || isDebug;

  // Intervalos de polling según entorno
  static Duration get pollingInterval {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return const Duration(minutes: 5);
      case AppEnvironment.uat:
      case AppEnvironment.qa:
        return const Duration(minutes: 2);
      case AppEnvironment.dev:
        return const Duration(minutes: 1); // Más frecuente en desarrollo
    }
  }

  // Configuración de cache
  static Duration get cacheTimeout {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return const Duration(hours: 1);
      case AppEnvironment.uat:
      case AppEnvironment.qa:
        return const Duration(minutes: 30);
      case AppEnvironment.dev:
        return const Duration(minutes: 5);
    }
  }

  // Configuración de retry
  static int get maxRetries {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return 3;
      case AppEnvironment.uat:
      case AppEnvironment.qa:
        return 2;
      case AppEnvironment.dev:
        return 1;
    }
  }

  static Duration get retryDelay {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return const Duration(seconds: 30);
      case AppEnvironment.uat:
      case AppEnvironment.qa:
        return const Duration(seconds: 15);
      case AppEnvironment.dev:
        return const Duration(seconds: 5);
    }
  }

  // Configuración de timeouts
  static Duration get connectionTimeout {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return const Duration(seconds: 30);
      case AppEnvironment.uat:
      case AppEnvironment.qa:
        return const Duration(seconds: 20);
      case AppEnvironment.dev:
        return const Duration(seconds: 10);
    }
  }

  static Duration get receiveTimeout {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return const Duration(seconds: 30);
      case AppEnvironment.uat:
      case AppEnvironment.qa:
        return const Duration(seconds: 20);
      case AppEnvironment.dev:
        return const Duration(seconds: 10);
    }
  }

  // Configuración de rate limiting
  static int get rateLimitRequests {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return 100;
      case AppEnvironment.uat:
      case AppEnvironment.qa:
        return 200;
      case AppEnvironment.dev:
        return 500;
    }
  }

  static Duration get rateLimitWindow {
    return const Duration(minutes: 1);
  }

  // Nombre del entorno para logging
  static String get environmentName {
    switch (currentEnvironment) {
      case AppEnvironment.pro:
        return 'production';
      case AppEnvironment.uat:
        return 'uat';
      case AppEnvironment.qa:
        return 'qa';
      case AppEnvironment.dev:
        return 'dev';
    }
  }
}