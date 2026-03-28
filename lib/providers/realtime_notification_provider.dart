import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kati_pilates/models/user_notification.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/providers/notification_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// State notifier that listens to real-time changes on user_notifications
/// and maintains a live unread count badge.
class RealtimeUnreadCountNotifier extends AsyncNotifier<int> {
  RealtimeChannel? _channel;

  @override
  Future<int> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return 0;

    // Initial count from database
    final count = await ref.read(notificationRepositoryProvider).getUnreadCount(user.id);

    // Set up real-time subscription
    _setupRealtime(user.id);

    // Cleanup subscription when provider is disposed
    ref.onDispose(() => _channel?.unsubscribe());

    return count;
  }

  void _setupRealtime(String userId) {
    _channel?.unsubscribe();

    _channel = Supabase.instance.client
        .channel('unread_notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => _refreshCount(userId),
        )
        .subscribe();
  }

  Future<void> _refreshCount(String userId) async {
    try {
      final count = await ref
          .read(notificationRepositoryProvider)
          .getUnreadCount(userId);
      state = AsyncValue.data(count);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await _refreshCount(user.id);
  }
}

/// Provider for real-time unread notification count (replaces unreadCountProvider in the badge).
final realtimeUnreadCountProvider =
    AsyncNotifierProvider<RealtimeUnreadCountNotifier, int>(
  RealtimeUnreadCountNotifier.new,
);

/// State notifier that listens for new user_notifications in real-time
/// and maintains the latest list.
class RealtimeNotificationsNotifier
    extends AsyncNotifier<List<UserNotification>> {
  RealtimeChannel? _channel;

  @override
  Future<List<UserNotification>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final notifications = await ref
        .read(notificationRepositoryProvider)
        .getUserNotifications(user.id);

    _setupRealtime(user.id);

    ref.onDispose(() => _channel?.unsubscribe());

    return notifications;
  }

  void _setupRealtime(String userId) {
    _channel?.unsubscribe();

    _channel = Supabase.instance.client
        .channel('notifications_feed:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => _refresh(userId),
        )
        .subscribe();
  }

  Future<void> _refresh(String userId) async {
    try {
      final notifications = await ref
          .read(notificationRepositoryProvider)
          .getUserNotifications(userId);
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref
        .read(notificationRepositoryProvider)
        .markAsRead(notificationId);

    // Update local state
    state = state.whenData(
      (notifications) => notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList(),
    );

    // Refresh unread count
    ref.invalidate(realtimeUnreadCountProvider);
  }

  Future<void> markAllAsRead() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref
        .read(notificationRepositoryProvider)
        .markAllAsRead(user.id);

    state = state.whenData(
      (notifications) =>
          notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );

    ref.invalidate(realtimeUnreadCountProvider);
  }
}

/// Provider for real-time notification feed.
final realtimeNotificationsProvider =
    AsyncNotifierProvider<RealtimeNotificationsNotifier, List<UserNotification>>(
  RealtimeNotificationsNotifier.new,
);
