import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/status_badge.dart';

class BookingListItem extends StatelessWidget {
  final BookingDetailed booking;

  /// Called when the user taps the cancel button.
  /// Only shown for upcoming confirmed bookings.
  final VoidCallback? onCancel;

  const BookingListItem({
    super.key,
    required this.booking,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: AppColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: class name + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    booking.className ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildBadge(),
              ],
            ),
            const SizedBox(height: 8),
            // Date and time
            if (booking.classDate != null && booking.classStartTime != null)
              Text(
                _formatDateTime(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 4),
            // Instructor
            if (booking.instructorName != null &&
                booking.instructorName!.isNotEmpty)
              Text(
                booking.instructorName!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            // Cancel button for upcoming confirmed bookings
            if (onCancel != null &&
                booking.status == BookingStatus.confirmed) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Tühista'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime() {
    if (booking.classDate == null || booking.classStartTime == null) return '';

    final dateStr = DateFormatter.formatShortDate(booking.classDate!);
    final timeStr = DateFormatter.formatTime(booking.classStartTime!);
    return '$dateStr \u00b7 $timeStr';
  }

  Widget _buildBadge() {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return StatusBadge.confirmed();
      case BookingStatus.waitlisted:
        return StatusBadge.waitlist();
      case BookingStatus.cancelled:
        return StatusBadge.cancelled();
      case BookingStatus.attended:
        return StatusBadge.attended();
      case BookingStatus.noShow:
        return const StatusBadge(
          label: 'Puudumine',
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
    }
  }
}
