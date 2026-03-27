import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_notification.freezed.dart';
part 'admin_notification.g.dart';

enum NotificationType {
  @JsonValue('uudine')
  uudine,
  @JsonValue('meeldetuletus')
  meeldetuletus,
  @JsonValue('oluline')
  oluline,
}

enum NotificationStatus {
  @JsonValue('sent')
  sent,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('draft')
  draft,
}

@freezed
abstract class AdminNotification with _$AdminNotification {
  const factory AdminNotification({
    required String id,
    @JsonKey(name: 'sender_id') required String senderId,
    required String subject,
    required String body,
    @JsonKey(name: 'notification_type') @Default(NotificationType.uudine) NotificationType notificationType,
    @Default(NotificationStatus.draft) NotificationStatus status,
    @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
    @JsonKey(name: 'sent_at') DateTime? sentAt,
    @JsonKey(name: 'total_recipients') @Default(0) int totalRecipients,
    @JsonKey(name: 'opened_count') @Default(0) int openedCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AdminNotification;

  factory AdminNotification.fromJson(Map<String, dynamic> json) =>
      _$AdminNotificationFromJson(json);
}
