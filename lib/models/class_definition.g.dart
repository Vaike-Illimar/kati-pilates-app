// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassDefinition _$ClassDefinitionFromJson(Map<String, dynamic> json) =>
    _ClassDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      level:
          $enumDecodeNullable(_$ClassLevelEnumMap, json['level']) ??
          ClassLevel.koik,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      maxParticipants: (json['max_participants'] as num).toInt(),
      studioId: json['studio_id'] as String?,
      instructorId: json['instructor_id'] as String?,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: json['start_time'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ClassDefinitionToJson(_ClassDefinition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'level': _$ClassLevelEnumMap[instance.level]!,
      'duration_minutes': instance.durationMinutes,
      'max_participants': instance.maxParticipants,
      'studio_id': instance.studioId,
      'instructor_id': instance.instructorId,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$ClassLevelEnumMap = {
  ClassLevel.algaja: 'algaja',
  ClassLevel.kesktase: 'kesktase',
  ClassLevel.koik: 'koik',
};
