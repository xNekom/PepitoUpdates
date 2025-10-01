import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../generated/app_localizations.dart';

part 'pepito_activity.g.dart';

/// Convierte un timestamp de la API a DateTime
/// La API puede devolver el timestamp como int (segundos) o String (ISO 8601)
DateTime _timestampFromJson(dynamic value) {
  if (value is int) {
    // Timestamp en segundos, convertir a milisegundos
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  } else if (value is String) {
    // Intentar parsear como ISO 8601
    try {
      return DateTime.parse(value);
    } catch (e) {
      // Si falla, intentar convertir a int primero
      try {
        final intValue = int.parse(value);
        return DateTime.fromMillisecondsSinceEpoch(intValue * 1000);
      } catch (e2) {
        // Fallback: usar fecha actual
        return DateTime.now();
      }
    }
  } else {
    // Fallback: usar fecha actual
    return DateTime.now();
  }
}

enum ActivityType {
  @JsonValue('in')
  entrada,
  @JsonValue('out')
  salida,
  all,
}

@JsonSerializable()
class PepitoActivity {
  final String? id;
  final String event;
  final String type; // 'in' o 'out'
  @JsonKey(name: 'time', fromJson: _timestampFromJson)
  final DateTime timestamp;
  final String? img;
  final String? imageUrl; // URL de imagen alternativa
  final String? location;
  final double? confidence;
  final Map<String, dynamic>? metadata;
  final String? source; // 'api', 'cache', 'local'
  final bool cached; // Si los datos vienen del cache
  final bool authenticated; // Si la request estaba autenticada
  final DateTime? createdAt; // Timestamp de creación local
  final DateTime? updatedAt; // Timestamp de última actualización

  const PepitoActivity({
    this.id,
    required this.event,
    required this.type,
    required this.timestamp,
    this.img,
    this.imageUrl,
    this.location,
    this.confidence,
    this.metadata,
    this.source,
    this.cached = false,
    this.authenticated = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PepitoActivity.fromJson(Map<String, dynamic> json) =>
      _$PepitoActivityFromJson(json);

  Map<String, dynamic> toJson() => _$PepitoActivityToJson(this);

  bool get isEntry => type.toLowerCase() == 'in';
  bool get isExit => type.toLowerCase() == 'out';

  String get displayType => isEntry ? '🏠 Entrada' : '🚪 Salida';

  String displayTypeLocalized(BuildContext context) => isEntry 
      ? '🏠 ${AppLocalizations.of(context)!.entry}' 
      : '🚪 ${AppLocalizations.of(context)!.exit}';

  DateTime get dateTime => timestamp;

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    return '$day/$month/$year';
  }

  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  /// Indica si la actividad es reciente (menos de 5 minutos)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(timestamp).inMinutes < 5;
  }

  /// Indica si los datos son confiables
  bool get isReliable {
    return source == 'api' && !cached && (confidence ?? 1.0) > 0.8;
  }

  /// Obtiene la URL de imagen preferida
  String? get preferredImageUrl {
    return imageUrl ?? img;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PepitoActivity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PepitoActivity(id: $id, type: $type, timestamp: $timestamp)';
  }

  PepitoActivity copyWith({
    String? id,
    String? event,
    String? type,
    DateTime? timestamp,
    String? img,
    String? imageUrl,
    String? location,
    double? confidence,
    Map<String, dynamic>? metadata,
    String? source,
    bool? cached,
    bool? authenticated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PepitoActivity(
      id: id ?? this.id,
      event: event ?? this.event,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      img: img ?? this.img,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      source: source ?? this.source,
      cached: cached ?? this.cached,
      authenticated: authenticated ?? this.authenticated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class PepitoStatus {
  final String event;
  final String type; // 'in' o 'out'
  @JsonKey(name: 'time')
  final DateTime timestamp;
  final String? img;
  final bool cached;
  final bool authenticated;
  
  // Campos derivados para compatibilidad
  bool get isHome => type.toLowerCase() == 'in';
  DateTime get lastSeen => timestamp;
  String get status => isHome ? 'en_casa' : 'fuera';

  const PepitoStatus({
    required this.event,
    required this.type,
    required this.timestamp,
    this.img,
    this.cached = false,
    this.authenticated = false,
  });

  factory PepitoStatus.fromJson(Map<String, dynamic> json) =>
      _$PepitoStatusFromJson(json);

  Map<String, dynamic> toJson() => _$PepitoStatusToJson(this);

  String displayStatus(BuildContext context) {
    return isHome ? '🏠 ${AppLocalizations.of(context)!.atHome}' : '🌍 ${AppLocalizations.of(context)!.awayFromHome}';
  }

  String get displayStatusWithoutContext {
    return isHome ? '🏠 En casa' : '🌍 Fuera de casa';
  }

  String get statusEmoji {
    return isHome ? '🏠' : '🌍';
  }
  
  PepitoActivity? get lastActivity {
    return PepitoActivity(
      event: event,
      type: type,
      timestamp: timestamp,
      img: img,
      source: 'api',
      cached: cached,
      authenticated: authenticated,
      createdAt: DateTime.now(),
    );
  }
}