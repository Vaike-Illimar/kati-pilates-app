// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FixedGroup _$FixedGroupFromJson(Map<String, dynamic> json) => _FixedGroup(
  id: json['id'] as String,
  classDefinitionId: json['class_definition_id'] as String,
  name: json['name'] as String,
  maxMembers: (json['max_members'] as num).toInt(),
  isActive: json['is_active'] as bool? ?? true,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FixedGroupToJson(_FixedGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_definition_id': instance.classDefinitionId,
      'name': instance.name,
      'max_members': instance.maxMembers,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
