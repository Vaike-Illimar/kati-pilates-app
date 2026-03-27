import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/models/class_instance.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/status_badge.dart';

class ClassCardWidget extends StatelessWidget {
  final ClassInstanceWithDetails classInstance;

  /// The current user's booking status for this class, if any.
  final BookingStatus? bookingStatus;

  /// Waitlist position when status is [BookingStatus.waitlisted].
  final int? waitlistPosition;

  /// Called when the user taps the book / join waitlist button.
  final VoidCallback? onBook;

  /// Called when the user taps the cancel button.
  final VoidCallback? onCancel;

  const ClassCardWidget({
    super.key,
    required this.classInstance,
    this.bookingStatus,
    this.waitlistPosition,
    this.onBook,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final ci = classInstance;
    final startTime = DateFormatter.formatTime(ci.startTime);
    final endTime = DateFormatter.formatTime(ci.endTime);

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
            // Top row: time + details + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: times
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startTime,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endTime,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Middle: class details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ci.className ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [ci.instructorName, ci.studioName]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(' \u00b7 '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: status badge
                _buildBadge(),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom: action button
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    if (classInstance.isCancelled) {
      return StatusBadge.cancelled();
    }

    switch (bookingStatus) {
      case BookingStatus.confirmed:
        return StatusBadge.confirmed();
      case BookingStatus.waitlisted:
        return StatusBadge.waitlist();
      case BookingStatus.attended:
        return StatusBadge.attended();
      case BookingStatus.cancelled:
        return StatusBadge.cancelled();
      default:
        if (classInstance.availableSpots > 0) {
          return StatusBadge.available(classInstance.availableSpots);
        }
        return StatusBadge.waitlist();
    }
  }

  Widget _buildActionButton() {
    if (classInstance.isCancelled) {
      return const SizedBox.shrink();
    }

    // User has confirmed booking
    if (bookingStatus == BookingStatus.confirmed) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.textSecondary.withValues(alpha: 0.15),
                foregroundColor: AppColors.textSecondary,
                disabledBackgroundColor:
                    AppColors.textSecondary.withValues(alpha: 0.15),
                disabledForegroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShape.buttonRadius),
                ),
              ),
              child: const Text('Broneeritud'),
            ),
          ),
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Tühista'),
            ),
        ],
      );
    }

    // User is waitlisted
    if (bookingStatus == BookingStatus.waitlisted) {
      final posText = waitlistPosition != null
          ? 'Järjekorras ($waitlistPosition)'
          : 'Järjekorras';
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: null,
              child: Text(posText),
            ),
          ),
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Tühista'),
            ),
        ],
      );
    }

    // Class is full — join waitlist
    if (classInstance.availableSpots <= 0) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onBook,
          child: const Text('Liitu järjekorraga'),
        ),
      );
    }

    // Spots available — book
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onBook,
        child: const Text('Broneeri tund'),
      ),
    );
  }
}
