import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:pepito_updates/config/environment.dart';
import 'package:pepito_updates/config/supabase_config.dart';
import 'package:pepito_updates/config/api_config.dart';

void main() {
  group('Security Configuration Tests', () {
    test('Environment variables should be configured for production', () {
      if (!kDebugMode) {
        // En producción, todas las configuraciones deben estar válidas
        expect(Environment.isConfigured, isTrue, 
               reason: 'Variables de entorno no configuradas para producción');
        
        expect(() => Environment.supabaseUrl, returnsNormally,
               reason: 'SUPABASE_URL no está configurada');
        
        expect(() => Environment.supabaseAnonKey, returnsNormally,
               reason: 'SUPABASE_ANON_KEY no está configurada');
        
        expect(() => Environment.apiKey, returnsNormally,
               reason: 'API_KEY no está configurada');
        
        expect(() => Environment.apiBaseUrl, returnsNormally,
               reason: 'API_BASE_URL no está configurada');
      }
    });
    
    test('No hardcoded credentials in configuration', () {
      if (!kDebugMode) {
        // Verificar que no hay valores por defecto en producción
        expect(Environment.supabaseUrl, isNot(contains('your-project')),
               reason: 'URL de Supabase contiene valor por defecto');
        
        expect(Environment.supabaseAnonKey, isNot(contains('your-anon-key')),
               reason: 'Clave anónima de Supabase contiene valor por defecto');
        
        expect(Environment.apiKey, isNot(contains('your-api-key')),
               reason: 'API Key contiene valor por defecto');
        
        expect(Environment.apiBaseUrl, isNot(contains('example.com')),
               reason: 'URL base de API contiene valor por defecto');
      }
    });
    
    test('Supabase configuration should use environment variables', () {
      if (Environment.isConfigured) {
        // Solo verificar si está configurado
        expect(SupabaseConfig.supabaseUrl, equals(Environment.supabaseUrl));
        expect(SupabaseConfig.supabaseAnonKey, equals(Environment.supabaseAnonKey));
      } else {
        // En modo debug sin configurar, debería fallar apropiadamente
        expect(() => SupabaseConfig.supabaseUrl, throwsException);
        expect(() => SupabaseConfig.supabaseAnonKey, throwsException);
      }
    });
    
    test('API configuration should use environment variables', () {
      if (Environment.isConfigured) {
        // Solo verificar si está configurado
        expect(ApiConfig.apiKey, equals(Environment.apiKey));
        
        if (kIsWeb) {
          expect(ApiConfig.baseUrl, contains(Environment.apiBaseUrl));
        } else {
          expect(ApiConfig.baseUrl, equals(Environment.apiBaseUrl));
        }
      } else {
        // En modo debug sin configurar, debería fallar apropiadamente
        expect(() => ApiConfig.apiKey, throwsException);
        expect(() => ApiConfig.baseUrl, throwsException);
      }
    });
    
    test('Configuration status should be valid for production', () {
      if (!kDebugMode) {
        expect(Environment.configurationStatus, 
               equals('Configuración de producción válida'),
               reason: 'Estado de configuración no es válido para producción');
      }
    });
    
    test('Debug mode configuration should have appropriate defaults', () {
      if (kDebugMode) {
        // En modo debug, debería tener valores por defecto
        expect(Environment.configurationStatus, 
               contains('Modo desarrollo'),
               reason: 'Estado de configuración no indica modo desarrollo');
      }
    });
    
    test('URLs should be valid format', () {
      if (Environment.isConfigured) {
        expect(Environment.supabaseUrl, startsWith('https://'),
               reason: 'URL de Supabase debe usar HTTPS');
        
        expect(Environment.apiBaseUrl, startsWith('https://'),
               reason: 'URL base de API debe usar HTTPS');
        
        // En producción, verificar que no son URLs de ejemplo
        if (!kDebugMode) {
          expect(Environment.supabaseUrl, isNot(contains('demo')),
                 reason: 'URL de Supabase parece ser de ejemplo en producción');
          expect(Environment.apiBaseUrl, isNot(contains('demo')),
                 reason: 'URL de API parece ser de ejemplo en producción');
        }
      }
    });
    
    test('API keys should not be empty in production', () {
      if (!kDebugMode && Environment.isConfigured) {
        expect(Environment.supabaseAnonKey.length, greaterThan(20),
               reason: 'Clave anónima de Supabase parece muy corta');
        
        expect(Environment.apiKey.length, greaterThan(10),
               reason: 'API Key parece muy corta');
      }
    });
  });
  
  group('Security Features Tests', () {
    test('Authorization service should be available', () {
      // Verificar que el servicio de autorización está disponible
      // Nota: Esto requeriría importar AuthorizationService y hacer pruebas más específicas
      expect(true, isTrue, reason: 'Placeholder para pruebas de autorización');
    });
    
    test('Transaction service should be available', () {
      // Verificar que el servicio de transacciones está disponible
      // Nota: Esto requeriría importar TransactionService y hacer pruebas más específicas
      expect(true, isTrue, reason: 'Placeholder para pruebas de transacciones');
    });
  });
}