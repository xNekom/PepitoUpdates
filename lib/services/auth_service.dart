import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  String? _cachedToken;
  DateTime? _tokenExpiry;
  
  // Cache de tokens por 50 minutos (los tokens de Supabase duran 1 hora)
  static const Duration _tokenCacheDuration = Duration(minutes: 50);
  
  /// Obtiene el token JWT actual, renovándolo si es necesario
  Future<String?> getCurrentToken() async {
    try {
      // Verificar si tenemos un token en cache válido
      if (_cachedToken != null && 
          _tokenExpiry != null && 
          DateTime.now().isBefore(_tokenExpiry!)) {
        return _cachedToken;
      }
      
      // Obtener sesión actual
      final session = _supabase.auth.currentSession;
      if (session?.accessToken != null) {
        _cachedToken = session!.accessToken;
        _tokenExpiry = DateTime.now().add(_tokenCacheDuration);
        return _cachedToken;
      }
      
      // Intentar renovar la sesión
      final response = await _supabase.auth.refreshSession();
      if (response.session?.accessToken != null) {
        _cachedToken = response.session!.accessToken;
        _tokenExpiry = DateTime.now().add(_tokenCacheDuration);
        return _cachedToken;
      }
      
      return null;
    } catch (e) {
      Logger.error('Error obteniendo token JWT', e);
      return null;
    }
  }
  
  /// Autentica al usuario de forma anónima para acceso básico
  Future<bool> authenticateAnonymously() async {
    try {
      // Generar un ID único para el dispositivo
      final deviceId = await _generateDeviceId();
      
      // Crear usuario anónimo con metadata del dispositivo
      final response = await _supabase.auth.signInAnonymously(
        data: {
          'device_id': deviceId,
          'app_version': '1.0.0',
          'platform': Platform.operatingSystem,
          'created_at': DateTime.now().toIso8601String(),
        }
      );
      
      if (response.user != null) {
        _cachedToken = response.session?.accessToken;
        _tokenExpiry = DateTime.now().add(_tokenCacheDuration);
        Logger.info('Usuario autenticado anónimamente: ${response.user!.id}');
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('Error en autenticación anónima', e);
      return false;
    }
  }
  
  /// Autentica con email y contraseña
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _cachedToken = response.session?.accessToken;
        _tokenExpiry = DateTime.now().add(_tokenCacheDuration);
        Logger.info('Usuario autenticado con email: ${response.user!.email}');
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('Error en autenticación con email', e);
      return false;
    }
  }
  
  /// Registra un nuevo usuario
  Future<bool> signUpWithEmail(String email, String password, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final deviceId = await _generateDeviceId();
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'device_id': deviceId,
          'app_version': '1.0.0',
          'platform': Platform.operatingSystem,
          'created_at': DateTime.now().toIso8601String(),
          ...?metadata,
        }
      );
      
      if (response.user != null) {
        Logger.info('Usuario registrado: ${response.user!.email}');
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('Error en registro de usuario', e);
      return false;
    }
  }
  
  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _cachedToken = null;
      _tokenExpiry = null;
      Logger.info('Usuario desconectado');
    } catch (e) {
      Logger.error('Error cerrando sesión', e);
    }
  }
  
  /// Verifica si el usuario está autenticado
  bool get isAuthenticated {
    return _supabase.auth.currentUser != null;
  }
  
  /// Obtiene el usuario actual
  User? get currentUser {
    return _supabase.auth.currentUser;
  }
  
  /// Verifica si el usuario tiene permisos de administrador
  bool get isAdmin {
    final user = currentUser;
    if (user?.userMetadata == null) return false;
    
    return user!.userMetadata!['role'] == 'admin' ||
           user.userMetadata!['is_admin'] == true;
  }
  
  /// Genera un ID único para el dispositivo
  Future<String> _generateDeviceId() async {
    try {
      // Combinar información del dispositivo para crear un ID único
      final deviceInfo = {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final deviceString = json.encode(deviceInfo);
      final bytes = utf8.encode(deviceString);
      final digest = sha256.convert(bytes);
      
      return digest.toString().substring(0, 32);
    } catch (e) {
      // Fallback a un ID basado en timestamp
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  /// Valida la fortaleza de una contraseña
  static bool isPasswordStrong(String password) {
    if (password.length < 8) return false;
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }
  
  /// Sanitiza el email de entrada
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }
  
  /// Escucha cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
