// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassInstance _$ClassInstanceFromJson(Map<String, dynamic> json) =>
    _ClassInstance(
      id: json['id'] as String,
      classDefinitionId: json['class_definition_id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      instructorId: json['instructor_id'] as String?,
      studioId: json['studio_id'] as String?,
      maxParticipants: (json['max_participants'] as num).toInt(),
      isCancelled: json['is_cancelled'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ClassInstanceToJson(_ClassInstance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_definition_id': instance.classDefinitionId,
      'date': instance.date.toIso8601String(),
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'instructor_id': instance.instructorId,
      'studio_id': instance.studioId,
      'max_participants': instance.maxParticipants,
      'is_cancelled': instance.isCancelled,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
    };
