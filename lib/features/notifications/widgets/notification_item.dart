import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/user_notification.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationItem extends StatelessWidget {
  final UserNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
  });

  Color get _dotColor {
    if (notification.isRead) return AppColors.textSecondary.withValues(alpha: 0.4);

    switch (notification.sourceType) {
      case 'booking':
        return AppColors.success;
      case 'card':
        return AppColors.warning;
      case 'waitlist':
        return AppColors.primary;
      case 'cancellation':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final relativeTime = timeago.format(notification.createdAt, locale: 'et');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppShape.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.cardWhite
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          border: notification.isRead
              ? null
              : Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  width: 1,
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored dot indicator
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dotColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title and body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          notification.isRead ? FontWeight.w500 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Timestamp and optional action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  relativeTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (notification.actionLabel != null &&
                    notification.actionUrl != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${notification.actionLabel} \u2192',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
