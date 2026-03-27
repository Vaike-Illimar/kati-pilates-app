import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_notification.freezed.dart';
part 'user_notification.g.dart';

@freezed
abstract class UserNotification with _$UserNotification {
  const factory UserNotification({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    required String body,
    @JsonKey(name: 'action_url') String? actionUrl,
    @JsonKey(name: 'action_label') String? actionLabel,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'source_type') String? sourceType,
    @JsonKey(name: 'source_id') String? sourceId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserNotification;

  factory UserNotification.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationFromJson(json);
}
