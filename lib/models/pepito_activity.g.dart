// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pepito_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PepitoActivity _$PepitoActivityFromJson(Map<String, dynamic> json) =>
    PepitoActivity(
      id: json['id'] as String?,
      event: json['event'] as String,
      type: json['type'] as String,
      timestamp: _timestampFromJson(json['time']),
      img: json['img'] as String?,
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      source: json['source'] as String?,
      cached: json['cached'] as bool? ?? false,
      authenticated: json['authenticated'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PepitoActivityToJson(PepitoActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event': instance.event,
      'type': instance.type,
      'time': instance.timestamp.toIso8601String(),
      'img': instance.img,
      'imageUrl': instance.imageUrl,
      'location': instance.location,
      'confidence': instance.confidence,
      'metadata': instance.metadata,
      'source': instance.source,
      'cached': instance.cached,
      'authenticated': instance.authenticated,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

PepitoStatus _$PepitoStatusFromJson(Map<String, dynamic> json) => PepitoStatus(
  event: json['event'] as String,
  type: json['type'] as String,
  timestamp: DateTime.parse(json['time'] as String),
  img: json['img'] as String?,
  cached: json['cached'] as bool? ?? false,
  authenticated: json['authenticated'] as bool? ?? false,
);

Map<String, dynamic> _$PepitoStatusToJson(PepitoStatus instance) =>
    <String, dynamic>{
      'event': instance.event,
      'type': instance.type,
      'time': instance.timestamp.toIso8601String(),
      'img': instance.img,
      'cached': instance.cached,
      'authenticated': instance.authenticated,
    };
