// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Studio _$StudioFromJson(Map<String, dynamic> json) => _Studio(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  capacity: (json['capacity'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$StudioToJson(_Studio instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'capacity': instance.capacity,
  'created_at': instance.createdAt.toIso8601String(),
};
