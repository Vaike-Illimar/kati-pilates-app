import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/providers/notification_provider.dart';
import 'package:kati_pilates/providers/realtime_notification_provider.dart';
import 'package:kati_pilates/shared/widgets/empty_state.dart';
import 'package:kati_pilates/features/notifications/widgets/notification_item.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initTimeago();
  }

  void _initTimeago() {
    if (!_initialized) {
      timeago.setLocaleMessages('et', _EstonianMessages());
      _initialized = true;
    }
  }

  Future<void> _markAllAsRead() async {
    // Use the real-time notifier which handles mark all read and updates state
    await ref.read(realtimeNotificationsProvider.notifier).markAllAsRead();
  }

  Future<void> _onNotificationTap(
    String notificationId,
    bool isRead,
    String? actionUrl,
  ) async {
    if (!isRead) {
      await ref.read(realtimeNotificationsProvider.notifier).markAsRead(notificationId);
    }

    if (actionUrl != null && actionUrl.isNotEmpty && mounted) {
      context.push(actionUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use real-time provider — updates instantly when new notifications arrive
    final notificationsAsync = ref.watch(realtimeNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Teavitused',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text(
                      'Märgi kõik loetuks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Viga teavituste laadimisel',
                  subtitle: 'Palun proovi uuesti.',
                  actionLabel: 'Proovi uuesti',
                  onAction: () => ref.invalidate(notificationsProvider),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'Teavitusi pole',
                      subtitle: 'Uued teavitused ilmuvad siia.',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(realtimeNotificationsProvider);
                      ref.invalidate(realtimeUnreadCountProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return NotificationItem(
                          notification: notification,
                          onTap: () => _onNotificationTap(
                            notification.id,
                            notification.isRead,
                            notification.actionUrl,
                          ),
                          onMarkRead: () async {
                            if (!notification.isRead) {
                              await ref
                                  .read(realtimeNotificationsProvider.notifier)
                                  .markAsRead(notification.id);
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estonian locale messages for timeago package.
class _EstonianMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'tagasi';
  @override
  String suffixFromNow() => 'pärast';
  @override
  String lessThanOneMinute(int seconds) => 'just praegu';
  @override
  String aboutAMinute(int minutes) => '1 min';
  @override
  String minutes(int minutes) => '$minutes min';
  @override
  String aboutAnHour(int minutes) => '1 tund';
  @override
  String hours(int hours) => '$hours tundi';
  @override
  String aDay(int hours) => 'Eile';
  @override
  String days(int days) => '$days päeva';
  @override
  String aboutAMonth(int days) => '1 kuu';
  @override
  String months(int months) => '$months kuud';
  @override
  String aboutAYear(int year) => '1 aasta';
  @override
  String years(int years) => '$years aastat';
  @override
  String wordSeparator() => ' ';
}
