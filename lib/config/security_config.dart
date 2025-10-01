import '../middleware/rate_limiting_middleware.dart';
import '../middleware/input_validation_middleware.dart';
import '../middleware/security_middleware.dart';

/// Configuración principal del sistema de seguridad
class AppSecurityConfig {
  /// Configuración de rate limiting
  static const RateLimitConfig rateLimitConfig = RateLimitConfig(
    maxRequests: 100,
    window: Duration(minutes: 1),
    blockDuration: Duration(minutes: 5),
    exemptPaths: [
      '/health',
      '/status',
    ],
    pathSpecificLimits: {
      '/api/auth/login': 5,
      '/api/auth/register': 3,
    },
  );
  
  /// Configuración de validación de entrada
  static const InputValidationConfig inputValidationConfig = InputValidationConfig(
    maxRequestSize: 10 * 1024 * 1024, // 10MB
    maxStringLength: 10000,
    enableSqlInjectionDetection: true,
    enableXssDetection: true,
    enableCommandInjectionDetection: true,
    enablePathTraversalDetection: true,
    allowedFileExtensions: ['.jpg', '.jpeg', '.png', '.gif', '.pdf', '.txt'],
    blockedPatterns: [
      r'<script[^>]*>.*?</script>',
      r'javascript:',
      r'vbscript:',
      r'onload\s*=',
      r'onerror\s*=',
    ],
    fieldRules: {},
  );
  
  /// Configuración del middleware de seguridad principal
  static const SecurityConfig securityConfig = SecurityConfig(
    rateLimitConfig: rateLimitConfig,
    inputValidationConfig: inputValidationConfig,
    enableBehaviorAnalysis: true,
    enableRequestLogging: true,
    enableResponseLogging: true,
    trustedProxies: [
      '10.0.0.0/8',
      '172.16.0.0/12',
      '192.168.0.0/16',
    ],
    securityHeaders: {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload',
      'Referrer-Policy': 'strict-origin-when-cross-origin',
      'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' https:; connect-src 'self' https:; frame-ancestors 'none';",
      'Permissions-Policy': 'geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), speaker=()',
      'X-Permitted-Cross-Domain-Policies': 'none',
      'Cross-Origin-Embedder-Policy': 'require-corp',
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Resource-Policy': 'same-origin',
    },
  );
  
  /// Configuración para desarrollo (menos restrictiva)
  static const SecurityConfig developmentConfig = SecurityConfig(
    rateLimitConfig: RateLimitConfig(
      maxRequests: 1000,
      window: Duration(minutes: 1),
      blockDuration: Duration(minutes: 1),
      exemptPaths: ['/health', '/debug'],
    ),
    inputValidationConfig: InputValidationConfig(
      maxRequestSize: 50 * 1024 * 1024, // 50MB
      maxStringLength: 50000,
      enableSqlInjectionDetection: true,
      enableXssDetection: true,
      enableCommandInjectionDetection: false,
      enablePathTraversalDetection: true,
      allowedFileExtensions: ['.jpg', '.jpeg', '.png', '.gif', '.pdf', '.txt', '.json'],
      blockedPatterns: [],
    ),
    enableBehaviorAnalysis: false,
    enableRequestLogging: true,
    enableResponseLogging: false,
    trustedProxies: [
      '127.0.0.0/8',
      '10.0.0.0/8',
      '172.16.0.0/12',
      '192.168.0.0/16',
    ],
    securityHeaders: {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'SAMEORIGIN',
      'X-XSS-Protection': '1; mode=block',
      'Referrer-Policy': 'strict-origin-when-cross-origin',
    },
  );
  
  /// Configuración para testing (mínima)
  static const SecurityConfig testingConfig = SecurityConfig(
    rateLimitConfig: RateLimitConfig(
      maxRequests: 10000,
      window: Duration(seconds: 1),
      blockDuration: Duration(seconds: 1),
      exemptPaths: ['/health', '/test'],
    ),
    inputValidationConfig: InputValidationConfig(
      maxRequestSize: 100 * 1024 * 1024, // 100MB
      maxStringLength: 100000,
      enableSqlInjectionDetection: false,
      enableXssDetection: false,
      enableCommandInjectionDetection: false,
      enablePathTraversalDetection: false,
      allowedFileExtensions: [],
      blockedPatterns: [],
    ),
    enableBehaviorAnalysis: false,
    enableRequestLogging: false,
    enableResponseLogging: false,
    trustedProxies: [],
    securityHeaders: {},
  );
  
  /// Obtiene la configuración según el entorno
  static SecurityConfig getConfigForEnvironment(String environment) {
    switch (environment.toLowerCase()) {
      case 'development':
      case 'dev':
        return developmentConfig;
      case 'testing':
      case 'test':
        return testingConfig;
      case 'production':
      case 'prod':
      default:
        return securityConfig;
    }
  }
  
  /// Configuración de endpoints críticos con rate limiting más estricto
  static const Map<String, RateLimitConfig> criticalEndpointsConfig = {
    '/auth/login': RateLimitConfig(
      maxRequests: 5,
      window: Duration(minutes: 1),
      blockDuration: Duration(minutes: 15),
    ),
    '/auth/register': RateLimitConfig(
      maxRequests: 3,
      window: Duration(minutes: 5),
      blockDuration: Duration(minutes: 30),
    ),
    '/auth/reset-password': RateLimitConfig(
      maxRequests: 2,
      window: Duration(minutes: 10),
      blockDuration: Duration(hours: 1),
    ),
    '/admin': RateLimitConfig(
      maxRequests: 50,
      window: Duration(minutes: 1),
      blockDuration: Duration(minutes: 10),
    ),
  };
  
  /// Configuración de validación específica por endpoint
  static const Map<String, InputValidationConfig> endpointValidationConfig = {
    '/auth/login': InputValidationConfig(
      maxRequestSize: 1024, // 1KB
      maxStringLength: 1000,
      enableSqlInjectionDetection: true,
      enableXssDetection: true,
      enableCommandInjectionDetection: true,
      enablePathTraversalDetection: true,
      allowedFileExtensions: [],
      blockedPatterns: [],
    ),
    '/auth/register': InputValidationConfig(
      maxRequestSize: 2048, // 2KB
      maxStringLength: 2000,
      enableSqlInjectionDetection: true,
      enableXssDetection: true,
      enableCommandInjectionDetection: true,
      enablePathTraversalDetection: true,
      allowedFileExtensions: [],
      blockedPatterns: [],
    ),
    '/upload': InputValidationConfig(
      maxRequestSize: 50 * 1024 * 1024, // 50MB
      maxStringLength: 10000,
      enableSqlInjectionDetection: true,
      enableXssDetection: true,
      enableCommandInjectionDetection: true,
      enablePathTraversalDetection: true,
      allowedFileExtensions: ['.jpg', '.jpeg', '.png', '.gif', '.pdf', '.txt'],
      blockedPatterns: [],
    ),
  };
  
  /// Lista de IPs de confianza (para desarrollo y testing)
  static const List<String> trustedIPs = [
    '127.0.0.1',
    '::1',
    'localhost',
  ];
  
  /// Lista de User-Agents bloqueados
  static const List<String> blockedUserAgents = [
    'sqlmap',
    'nikto',
    'nmap',
    'masscan',
    'zap',
    'burp',
    'w3af',
    'skipfish',
    'wfuzz',
    'dirb',
    'dirbuster',
    'gobuster',
    'ffuf',
    'hydra',
    'medusa',
    'john',
    'hashcat',
  ];
  
  /// Patrones de ataques comunes
  static const List<String> maliciousPatterns = [
    // SQL Injection
    r"(?i)(union|select|insert|update|delete|drop|create|alter|exec|execute)\s*\(",
    r"(?i)'\s*(or|and)\s*'?\d",
    r"(?i)'\s*(or|and)\s*'?'\s*'?",
    r"(?i)\bor\s+1\s*=\s*1\b",
    r"(?i)\band\s+1\s*=\s*1\b",
    
    // XSS
    r"(?i)<script[^>]*>.*?</script>",
    r"(?i)javascript:",
    r"(?i)on\w+\s*=",
    r"(?i)<iframe[^>]*>.*?</iframe>",
    r"(?i)<object[^>]*>.*?</object>",
    
    // Command Injection
    r"(?i);\s*(cat|ls|dir|type|more|less|head|tail|grep|find|locate)\s",
    r"(?i)\|\s*(cat|ls|dir|type|more|less|head|tail|grep|find|locate)\s",
    r"(?i)&&\s*(cat|ls|dir|type|more|less|head|tail|grep|find|locate)\s",
    r"(?i)\$\(.*?\)",
    r"(?i)`.*?`",
    
    // Path Traversal
    r"(?i)\.\./",
    r"(?i)\.\.\\\\",
    r"(?i)%2e%2e%2f",
    r"(?i)%2e%2e%5c",
    
    // LDAP Injection
    r"(?i)\*\)\(.*?=\*",
    r"(?i)\)\(\|\(.*?\)\)",
    
    // XML Injection
    r"(?i)<!\[CDATA\[",
    r"(?i)<!DOCTYPE",
    r"(?i)<!ENTITY",
  ];
}