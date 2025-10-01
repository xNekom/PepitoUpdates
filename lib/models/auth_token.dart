class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final DateTime refreshExpiresAt;
  final String tokenType;
  final List<String>? scopes;
  final Map<String, dynamic>? metadata;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.refreshExpiresAt,
    this.tokenType = 'Bearer',
    this.scopes,
    this.metadata,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      refreshExpiresAt: DateTime.parse(json['refresh_expires_at'] as String),
      tokenType: json['token_type'] as String? ?? 'Bearer',
      scopes: json['scopes'] != null
          ? List<String>.from(json['scopes'] as List)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'refresh_expires_at': refreshExpiresAt.toIso8601String(),
      'token_type': tokenType,
      'scopes': scopes,
      'metadata': metadata,
    };
  }

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? refreshExpiresAt,
    String? tokenType,
    List<String>? scopes,
    Map<String, dynamic>? metadata,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      refreshExpiresAt: refreshExpiresAt ?? this.refreshExpiresAt,
      tokenType: tokenType ?? this.tokenType,
      scopes: scopes ?? this.scopes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica si el token de acceso ha expirado
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Verifica si el token de acceso expirará pronto (en los próximos 5 minutos)
  bool get willExpireSoon {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  /// Verifica si el refresh token ha expirado
  bool get isRefreshExpired {
    return DateTime.now().isAfter(refreshExpiresAt);
  }

  /// Verifica si el refresh token expirará pronto (en las próximas 24 horas)
  bool get refreshWillExpireSoon {
    final twentyFourHoursFromNow = DateTime.now().add(const Duration(hours: 24));
    return twentyFourHoursFromNow.isAfter(refreshExpiresAt);
  }

  /// Verifica si el token es válido (no expirado)
  bool get isValid {
    return !isExpired;
  }

  /// Verifica si el refresh token es válido (no expirado)
  bool get isRefreshValid {
    return !isRefreshExpired;
  }

  /// Obtiene el tiempo restante hasta la expiración del token de acceso
  Duration get timeUntilExpiration {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }

  /// Obtiene el tiempo restante hasta la expiración del refresh token
  Duration get timeUntilRefreshExpiration {
    final now = DateTime.now();
    if (now.isAfter(refreshExpiresAt)) {
      return Duration.zero;
    }
    return refreshExpiresAt.difference(now);
  }

  /// Verifica si el token tiene un scope específico
  bool hasScope(String scope) {
    if (scopes == null) return false;
    return scopes!.contains(scope) || scopes!.contains('*');
  }

  /// Verifica si el token tiene alguno de los scopes especificados
  bool hasAnyScope(List<String> requiredScopes) {
    if (scopes == null) return false;
    if (scopes!.contains('*')) return true;
    
    return requiredScopes.any((scope) => scopes!.contains(scope));
  }

  /// Verifica si el token tiene todos los scopes especificados
  bool hasAllScopes(List<String> requiredScopes) {
    if (scopes == null) return false;
    if (scopes!.contains('*')) return true;
    
    return requiredScopes.every((scope) => scopes!.contains(scope));
  }

  /// Obtiene el header de autorización para usar en requests HTTP
  String get authorizationHeader {
    return '$tokenType $accessToken';
  }

  /// Obtiene información del token como mapa para debugging
  Map<String, dynamic> get debugInfo {
    return {
      'token_type': tokenType,
      'expires_at': expiresAt.toIso8601String(),
      'refresh_expires_at': refreshExpiresAt.toIso8601String(),
      'is_expired': isExpired,
      'is_refresh_expired': isRefreshExpired,
      'will_expire_soon': willExpireSoon,
      'refresh_will_expire_soon': refreshWillExpireSoon,
      'time_until_expiration': timeUntilExpiration.toString(),
      'time_until_refresh_expiration': timeUntilRefreshExpiration.toString(),
      'scopes': scopes,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'AuthToken(tokenType: $tokenType, expiresAt: $expiresAt, isExpired: $isExpired)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthToken &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return Object.hash(accessToken, refreshToken);
  }
}

/// Estado del token de autenticación
enum TokenStatus {
  valid,
  expired,
  expiringSoon,
  refreshExpired,
  invalid,
}

/// Extensión para obtener el estado del token
extension AuthTokenStatus on AuthToken {
  TokenStatus get status {
    if (isRefreshExpired) {
      return TokenStatus.refreshExpired;
    }
    if (isExpired) {
      return TokenStatus.expired;
    }
    if (willExpireSoon) {
      return TokenStatus.expiringSoon;
    }
    if (isValid) {
      return TokenStatus.valid;
    }
    return TokenStatus.invalid;
  }

  /// Verifica si el token necesita ser refrescado
  bool get needsRefresh {
    return status == TokenStatus.expired || status == TokenStatus.expiringSoon;
  }

  /// Verifica si el token puede ser refrescado
  bool get canBeRefreshed {
    return status != TokenStatus.refreshExpired && isRefreshValid;
  }
}