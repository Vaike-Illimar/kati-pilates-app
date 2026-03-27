// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_group_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FixedGroupMember _$FixedGroupMemberFromJson(Map<String, dynamic> json) =>
    _FixedGroupMember(
      id: json['id'] as String,
      fixedGroupId: json['fixed_group_id'] as String,
      userId: json['user_id'] as String,
      status:
          $enumDecodeNullable(
            _$FixedGroupMemberStatusEnumMap,
            json['status'],
          ) ??
          FixedGroupMemberStatus.active,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      pausedAt: json['paused_at'] == null
          ? null
          : DateTime.parse(json['paused_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$FixedGroupMemberToJson(_FixedGroupMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fixed_group_id': instance.fixedGroupId,
      'user_id': instance.userId,
      'status': _$FixedGroupMemberStatusEnumMap[instance.status]!,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'paused_at': instance.pausedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$FixedGroupMemberStatusEnumMap = {
  FixedGroupMemberStatus.active: 'active',
  FixedGroupMemberStatus.paused: 'paused',
  FixedGroupMemberStatus.invited: 'invited',
  FixedGroupMemberStatus.declined: 'declined',
};
