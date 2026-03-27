import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/user_notification.dart';
import 'package:kati_pilates/models/admin_notification.dart';

class NotificationRepository {
  final SupabaseClient _client;

  NotificationRepository(this._client);

  // --- User notifications ---

  /// Get all notifications for a user, newest first.
  Future<List<UserNotification>> getUserNotifications(
    String userId,
  ) async {
    final data = await _client
        .from('user_notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data.map((json) => UserNotification.fromJson(json)).toList();
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('user_notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Mark all notifications for a user as read.
  Future<void> markAllAsRead(String userId) async {
    await _client
        .from('user_notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// Get the count of unread notifications for a user.
  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from('user_notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);
    return response.count;
  }

  // --- Admin notifications ---

  /// Admin: get all admin notifications.
  Future<List<AdminNotification>> getAdminNotifications() async {
    final data = await _client
        .from('admin_notifications')
        .select()
        .order('created_at', ascending: false);
    return data.map((json) => AdminNotification.fromJson(json)).toList();
  }

  /// Admin: get admin notifications filtered by status.
  Future<List<AdminNotification>> getAdminNotificationsByStatus(
    String status,
  ) async {
    final data = await _client
        .from('admin_notifications')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);
    return data.map((json) => AdminNotification.fromJson(json)).toList();
  }

  /// Admin: send a notification to selected recipients.
  Future<AdminNotification> sendNotification(
    String notificationId,
    List<String> recipientIds,
  ) async {
    // Insert recipient rows
    final recipientRows = recipientIds
        .map((uid) => {
              'notification_id': notificationId,
              'user_id': uid,
            })
        .toList();
    if (recipientRows.isNotEmpty) {
      await _client.from('notification_recipients').insert(recipientRows);
    }

    // Update notification status to sent
    final data = await _client
        .from('admin_notifications')
        .update({
          'status': 'sent',
          'sent_at': DateTime.now().toIso8601String(),
          'total_recipients': recipientIds.length,
        })
        .eq('id', notificationId)
        .select()
        .single();
    return AdminNotification.fromJson(data);
  }

  /// Admin: create a new notification to send to users.
  Future<AdminNotification> createNotification({
    required String senderId,
    required String subject,
    required String body,
    String? notificationType,
    DateTime? scheduledAt,
  }) async {
    final data = await _client
        .from('admin_notifications')
        .insert({
          'sender_id': senderId,
          'subject': subject,
          'body': body,
          if (notificationType != null)
            'notification_type': notificationType,
          if (scheduledAt != null)
            'scheduled_at': scheduledAt.toIso8601String(),
        })
        .select()
        .single();
    return AdminNotification.fromJson(data);
  }
}
