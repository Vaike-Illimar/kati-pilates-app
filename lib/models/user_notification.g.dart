// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserNotification _$UserNotificationFromJson(Map<String, dynamic> json) =>
    _UserNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      actionUrl: json['action_url'] as String?,
      actionLabel: json['action_label'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      sourceType: json['source_type'] as String?,
      sourceId: json['source_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserNotificationToJson(_UserNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'action_url': instance.actionUrl,
      'action_label': instance.actionLabel,
      'is_read': instance.isRead,
      'source_type': instance.sourceType,
      'source_id': instance.sourceId,
      'created_at': instance.createdAt.toIso8601String(),
    };
