class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime? lastLoginAt;
  final List<String>? permissions;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.isActive,
    this.metadata,
    this.lastLoginAt,
    this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'user',
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'metadata': metadata,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'permissions': permissions,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? lastLoginAt,
    List<String>? permissions,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      permissions: permissions ?? this.permissions,
    );
  }

  /// Verifica si el usuario tiene un permiso específico
  bool hasPermission(String permission) {
    if (permissions == null) return false;
    return permissions!.contains(permission) || permissions!.contains('*');
  }

  /// Verifica si el usuario tiene alguno de los permisos especificados
  bool hasAnyPermission(List<String> requiredPermissions) {
    if (permissions == null) return false;
    if (permissions!.contains('*')) return true;
    
    return requiredPermissions.any((permission) => permissions!.contains(permission));
  }

  /// Verifica si el usuario tiene todos los permisos especificados
  bool hasAllPermissions(List<String> requiredPermissions) {
    if (permissions == null) return false;
    if (permissions!.contains('*')) return true;
    
    return requiredPermissions.every((permission) => permissions!.contains(permission));
  }

  /// Verifica si el usuario es administrador
  bool get isAdmin => role == 'admin' || hasPermission('admin.*');

  /// Verifica si el usuario es moderador
  bool get isModerator => role == 'moderator' || hasPermission('moderate.*');

  /// Obtiene los permisos efectivos del usuario basados en su rol
  List<String> get effectivePermissions {
    final List<String> rolePermissions = _getRolePermissions(role);
    final List<String> userPermissions = permissions ?? [];
    
    // Combinar permisos de rol y permisos específicos del usuario
    final Set<String> allPermissions = {...rolePermissions, ...userPermissions};
    return allPermissions.toList();
  }

  /// Obtiene los permisos por defecto para un rol
  static List<String> _getRolePermissions(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return ['*']; // Todos los permisos
      case 'moderator':
        return [
          'users.read',
          'users.update',
          'content.read',
          'content.update',
          'content.delete',
          'reports.read',
          'reports.update',
        ];
      case 'editor':
        return [
          'content.read',
          'content.create',
          'content.update',
          'media.upload',
        ];
      case 'user':
      default:
        return [
          'profile.read',
          'profile.update',
          'content.read',
        ];
    }
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enumeración de roles disponibles
enum UserRole {
  admin('admin'),
  moderator('moderator'),
  editor('editor'),
  user('user'),
  guest('guest');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.value == role.toLowerCase(),
      orElse: () => UserRole.user,
    );
  }
}

/// Enumeración de permisos del sistema
class Permissions {
  // Permisos de usuario
  static const String userRead = 'users.read';
  static const String userCreate = 'users.create';
  static const String userUpdate = 'users.update';
  static const String userDelete = 'users.delete';
  
  // Permisos de perfil
  static const String profileRead = 'profile.read';
  static const String profileUpdate = 'profile.update';
  
  // Permisos de contenido
  static const String contentRead = 'content.read';
  static const String contentCreate = 'content.create';
  static const String contentUpdate = 'content.update';
  static const String contentDelete = 'content.delete';
  
  // Permisos de administración
  static const String adminAll = 'admin.*';
  static const String adminUsers = 'admin.users';
  static const String adminSystem = 'admin.system';
  static const String adminSecurity = 'admin.security';
  
  // Permisos de moderación
  static const String moderateAll = 'moderate.*';
  static const String moderateContent = 'moderate.content';
  static const String moderateUsers = 'moderate.users';
  
  // Permisos de reportes
  static const String reportsRead = 'reports.read';
  static const String reportsCreate = 'reports.create';
  static const String reportsUpdate = 'reports.update';
  
  // Permisos de media
  static const String mediaUpload = 'media.upload';
  static const String mediaDelete = 'media.delete';
  
  // Permisos de API
  static const String apiRead = 'api.read';
  static const String apiWrite = 'api.write';
  static const String apiAdmin = 'api.admin';
  
  /// Obtiene todos los permisos disponibles
  static List<String> get allPermissions => [
    userRead, userCreate, userUpdate, userDelete,
    profileRead, profileUpdate,
    contentRead, contentCreate, contentUpdate, contentDelete,
    adminAll, adminUsers, adminSystem, adminSecurity,
    moderateAll, moderateContent, moderateUsers,
    reportsRead, reportsCreate, reportsUpdate,
    mediaUpload, mediaDelete,
    apiRead, apiWrite, apiAdmin,
  ];
  
  /// Verifica si un permiso es válido
  static bool isValidPermission(String permission) {
    return allPermissions.contains(permission) || permission == '*';
  }
}