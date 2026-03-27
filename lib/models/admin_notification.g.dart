// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminNotification _$AdminNotificationFromJson(Map<String, dynamic> json) =>
    _AdminNotification(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      subject: json['subject'] as String,
      body: json['body'] as String,
      notificationType:
          $enumDecodeNullable(
            _$NotificationTypeEnumMap,
            json['notification_type'],
          ) ??
          NotificationType.uudine,
      status:
          $enumDecodeNullable(_$NotificationStatusEnumMap, json['status']) ??
          NotificationStatus.draft,
      scheduledAt: json['scheduled_at'] == null
          ? null
          : DateTime.parse(json['scheduled_at'] as String),
      sentAt: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      totalRecipients: (json['total_recipients'] as num?)?.toInt() ?? 0,
      openedCount: (json['opened_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AdminNotificationToJson(
  _AdminNotification instance,
) => <String, dynamic>{
  'id': instance.id,
  'sender_id': instance.senderId,
  'subject': instance.subject,
  'body': instance.body,
  'notification_type': _$NotificationTypeEnumMap[instance.notificationType]!,
  'status': _$NotificationStatusEnumMap[instance.status]!,
  'scheduled_at': instance.scheduledAt?.toIso8601String(),
  'sent_at': instance.sentAt?.toIso8601String(),
  'total_recipients': instance.totalRecipients,
  'opened_count': instance.openedCount,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$NotificationTypeEnumMap = {
  NotificationType.uudine: 'uudine',
  NotificationType.meeldetuletus: 'meeldetuletus',
  NotificationType.oluline: 'oluline',
};

const _$NotificationStatusEnumMap = {
  NotificationStatus.sent: 'sent',
  NotificationStatus.scheduled: 'scheduled',
  NotificationStatus.draft: 'draft',
};
