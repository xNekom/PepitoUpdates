import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../utils/logger.dart';
import '../models/user.dart';

/// Permisos específicos del sistema (usando el enum del modelo User)
typedef Permission = String;

/// Servicio de autorización para operaciones críticas y control de acceso basado en roles
class AuthorizationService {
  static final AuthorizationService _instance = AuthorizationService._internal();
  factory AuthorizationService() => _instance;
  AuthorizationService._internal();
  
  final AuthService _authService = AuthService();
  static const String _adminPassword = String.fromEnvironment(
    'ADMIN_PASSWORD',
    defaultValue: kDebugMode ? 'debug123' : '',
  );
  
  /// Cache de permisos del usuario actual
  List<String>? _cachedPermissions;
  String? _cachedUserId;
  DateTime? _cacheExpiry;
  
  /// Obtiene el usuario actual del sistema
  User? getCurrentUser() {
    if (!_authService.isAuthenticated) {
      return null;
    }
    
    final supabaseUser = _authService.currentUser;
    if (supabaseUser == null) return null;
    
    // Convertir el usuario de Supabase a nuestro modelo User
    final metadata = supabaseUser.userMetadata ?? {};
    final role = _parseUserRole(metadata['role'] as String?);
    
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: metadata['name'] as String? ?? supabaseUser.email ?? 'Usuario',
      role: role.name,
      createdAt: DateTime.parse(supabaseUser.createdAt),
      isActive: true,
      metadata: metadata,
      lastLoginAt: DateTime.now(),
    );
  }
  
  /// Convierte string a UserRole
  UserRole _parseUserRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.user;
    }
  }
  
  /// Obtiene el rol del usuario actual
  UserRole getCurrentUserRole() {
    final user = getCurrentUser();
    return user != null ? _parseUserRole(user.role) : UserRole.guest;
  }
  
  /// Obtiene los permisos del usuario actual (con cache)
  List<String> getCurrentUserPermissions() {
    final user = getCurrentUser();
    if (user == null) return <String>[];
    
    // Verificar cache
    if (_cachedPermissions != null && 
        _cachedUserId == user.id && 
        _cacheExpiry != null && 
        DateTime.now().isBefore(_cacheExpiry!)) {
      return _cachedPermissions!;
    }
    
    // Actualizar cache
    _cachedPermissions = user.effectivePermissions;
    _cachedUserId = user.id;
    _cacheExpiry = DateTime.now().add(const Duration(minutes: 5));
    
    return _cachedPermissions!;
  }
  
  /// Limpia el cache de permisos
  void clearPermissionsCache() {
    _cachedPermissions = null;
    _cachedUserId = null;
    _cacheExpiry = null;
  }
  
  /// Verifica si el usuario actual tiene un permiso específico
  bool hasPermission(String permission) {
    final permissions = getCurrentUserPermissions();
    return permissions.contains(permission);
  }
  
  /// Verifica si el usuario tiene alguno de los permisos especificados
  bool hasAnyPermission(List<String> permissions) {
    final userPermissions = getCurrentUserPermissions();
    return permissions.any((permission) => userPermissions.contains(permission));
  }
  
  /// Verifica si el usuario tiene todos los permisos especificados
  bool hasAllPermissions(List<String> permissions) {
    final userPermissions = getCurrentUserPermissions();
    return permissions.every((permission) => userPermissions.contains(permission));
  }
  
  /// Verifica si el usuario puede acceder a un recurso
  bool canAccess(String resource, {Map<String, dynamic>? context}) {
    final user = getCurrentUser();
    if (user == null) return false;
    
    switch (resource) {
      case 'debug_info':
        return hasPermission('accessDebugInfo') || kDebugMode;
      case 'admin_panel':
        return hasPermission('systemAdmin');
      case 'user_management':
        return hasPermission('manageUsers');
      case 'delete_operations':
        return hasPermission('deleteData');
      case 'activities':
        return hasPermission('viewActivities');
      case 'settings':
        return hasPermission('manageSettings');
      case 'security_monitoring':
        return hasPermission('viewSecurityLogs');
      case 'threat_prediction':
        return hasPermission('manageSecurity');
      case 'threat_response':
        return hasPermission('manageSecurity');
      default:
        Logger.warning('Recurso desconocido para autorización: $resource');
        return false;
    }
  }
  
  /// Verifica si el usuario puede acceder a una ruta específica
  bool canAccessRoute(String routeName, {Map<String, dynamic>? context}) {
    final user = getCurrentUser();
    if (user == null) return routeName == '/login' || routeName == '/register';
    
    switch (routeName) {
      case '/admin':
      case '/admin_panel':
        return user.isAdmin;
      case '/security':
      case '/security_monitor':
        return hasPermission('viewSecurityLogs');
      case '/threat_prediction':
        return hasPermission('manageSecurity');
      case '/user_management':
        return hasPermission('manageUsers');
      case '/settings':
        return hasPermission('manageSettings');
      default:
        return true; // Rutas públicas por defecto
    }
  }
  
  /// Registra un evento de autorización
  void _logAuthorizationEvent({
    required String operation,
    required bool granted,
    String? reason,
  }) {
    final user = _authService.currentUser;
    Logger.info(
      'Authorization: $operation - ${granted ? "GRANTED" : "DENIED"}'
      '${reason != null ? " ($reason)" : ""}'
      ' - User: ${user?.id ?? "anonymous"}'
      ' - Role: ${getCurrentUserRole().name}'
    );
  }
  
  /// Solicita autorización para operaciones destructivas
  Future<bool> requestAuthorization(
    BuildContext context, {
    required String operation,
    required String description,
    String? requiredPermission,
    bool requirePassword = false,
  }) async {
    // Verificar permisos basados en roles primero
    if (requiredPermission != null && !hasPermission('requiredPermission')) {
      _logAuthorizationEvent(
        operation: operation,
        granted: false,
        reason: 'Insufficient permissions',
      );
      
      await _showAccessDeniedDialog(context, operation, description);
      return false;
    }
    
    // Si requiere contraseña o es una operación crítica
    if (requirePassword || requiredPermission == 'deleteData' || requiredPermission == 'systemAdmin') {
      if (kDebugMode && !requirePassword) {
        // En modo debug, mostrar diálogo de confirmación simple para operaciones no críticas
        final result = await _showDebugConfirmation(context, operation, description);
        _logAuthorizationEvent(
          operation: operation,
          granted: result,
          reason: result ? 'Debug mode confirmation' : 'User cancelled',
        );
        return result;
      }
      
      // En producción o para operaciones críticas, requerir contraseña de administrador
      final result = await _showPasswordDialog(context, operation, description);
      _logAuthorizationEvent(
        operation: operation,
        granted: result,
        reason: result ? 'Password verified' : 'Password verification failed',
      );
      return result;
    }
    
    // Para operaciones normales con permisos adecuados
    final result = await _showConfirmationDialog(context, operation, description);
    _logAuthorizationEvent(
      operation: operation,
      granted: result,
      reason: result ? 'User confirmed' : 'User cancelled',
    );
    return result;
  }
  
  /// Método estático para compatibilidad hacia atrás
  static Future<bool> requestAuthorizationStatic(
    BuildContext context, {
    required String operation,
    required String description,
  }) async {
    final service = AuthorizationService();
    return await service.requestAuthorization(
      context,
      operation: operation,
      description: description,
      requirePassword: true,
    );
  }
  
  /// Muestra diálogo de acceso denegado
  Future<void> _showAccessDeniedDialog(
    BuildContext context,
    String operation,
    String description,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚫 Acceso Denegado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operación: $operation'),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            Text(
              'No tienes permisos suficientes para realizar esta operación. '
              'Rol actual: ${getCurrentUserRole().name}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
  
  /// Muestra diálogo de confirmación simple
  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String operation,
    String description,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar $operation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              const SizedBox(height: 16),
              Text(
                '¿Estás seguro de que deseas continuar?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  static Future<bool> _showDebugConfirmation(
    BuildContext context,
    String operation,
    String description,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('[DEBUG] $operation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              const SizedBox(height: 16),
              const Text(
                'Esta operación solo está disponible en modo desarrollo.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  static Future<bool> _showPasswordDialog(
    BuildContext context,
    String operation,
    String description,
  ) async {
    if (_adminPassword.isEmpty) {
      // Si no hay contraseña configurada, denegar acceso
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Acceso Denegado'),
          content: const Text(
            'Esta operación requiere autorización de administrador. '
            'La contraseña de administrador no está configurada.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return false;
    }
    
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('🔐 Autorización Requerida'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Operación: $operation'),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Contraseña de Administrador',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final isValid = passwordController.text == _adminPassword;
                    Navigator.of(context).pop(isValid);
                    if (!isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contraseña incorrecta'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Autorizar'),
                ),
              ],
            );
          },
        );
      },
    ) ?? false;
  }
}
