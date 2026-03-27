import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/user_notification.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/repositories/notification_repository.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});

final notificationsProvider =
    FutureProvider.autoDispose<List<UserNotification>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final notifRepo = ref.watch(notificationRepositoryProvider);
  return notifRepo.getUserNotifications(user.id);
});

final unreadCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final notifRepo = ref.watch(notificationRepositoryProvider);
  return notifRepo.getUnreadCount(user.id);
});
