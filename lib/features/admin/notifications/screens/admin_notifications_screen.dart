import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/admin_notification.dart';
import 'package:kati_pilates/providers/notification_provider.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/empty_state.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _sentNotificationsProvider =
    FutureProvider.autoDispose<List<AdminNotification>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getAdminNotificationsByStatus('sent');
});

final _scheduledNotificationsProvider =
    FutureProvider.autoDispose<List<AdminNotification>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getAdminNotificationsByStatus('scheduled');
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends ConsumerState<AdminNotificationsScreen> {
  int _selectedTab = 0; // 0 = Saadetud, 1 = Ajastatud

  @override
  Widget build(BuildContext context) {
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
                  FilledButton.icon(
                    onPressed: () => context.push('/admin/notifications/create'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Saada teavitus'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _TabPill(
                    label: 'Saadetud',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(width: 8),
                  _TabPill(
                    label: 'Ajastatud',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),

            // Notification list
            Expanded(
              child: _selectedTab == 0
                  ? _NotificationList(
                      asyncValue: ref.watch(_sentNotificationsProvider),
                      emptyTitle: 'Saadetud teavitusi pole',
                      emptySubtitle: 'Saadetud teavitused ilmuvad siia.',
                      onRefresh: () {
                        ref.invalidate(_sentNotificationsProvider);
                      },
                    )
                  : _NotificationList(
                      asyncValue: ref.watch(_scheduledNotificationsProvider),
                      emptyTitle: 'Ajastatud teavitusi pole',
                      emptySubtitle: 'Ajastatud teavitused ilmuvad siia.',
                      onRefresh: () {
                        ref.invalidate(_scheduledNotificationsProvider);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab pill
// ---------------------------------------------------------------------------

class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppShape.buttonRadius),
          border: isSelected
              ? null
              : Border.all(color: AppColors.primaryLight, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notification list (shared between tabs)
// ---------------------------------------------------------------------------

class _NotificationList extends StatelessWidget {
  final AsyncValue<List<AdminNotification>> asyncValue;
  final String emptyTitle;
  final String emptySubtitle;
  final VoidCallback onRefresh;

  const _NotificationList({
    required this.asyncValue,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => EmptyState(
        icon: Icons.error_outline,
        title: 'Viga laadimisel',
        subtitle: 'Palun proovi uuesti.',
        actionLabel: 'Proovi uuesti',
        onAction: onRefresh,
      ),
      data: (notifications) {
        if (notifications.isEmpty) {
          return EmptyState(
            icon: Icons.notifications_none_rounded,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => onRefresh(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _NotificationCard(notification: notifications[index]);
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Notification card
// ---------------------------------------------------------------------------

class _NotificationCard extends StatelessWidget {
  final AdminNotification notification;

  const _NotificationCard({required this.notification});

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.uudine:
        return Icons.newspaper_rounded;
      case NotificationType.meeldetuletus:
        return Icons.alarm_rounded;
      case NotificationType.oluline:
        return Icons.priority_high_rounded;
    }
  }

  String _timeLabel() {
    final date = notification.sentAt ?? notification.scheduledAt ?? notification.createdAt;
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '${DateFormatter.formatRelativeDate(date)} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final openRate = notification.totalRecipients > 0
        ? 'Avatud ${notification.openedCount}/${notification.totalRecipients}'
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForType(notification.notificationType),
              color: AppColors.primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Kõik kliendid \u00b7 ${_timeLabel()}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (openRate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    openRate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
