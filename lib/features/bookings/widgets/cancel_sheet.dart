import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';

/// Shows a bottom sheet asking the user to confirm cancellation.
/// Returns `true` if the user confirmed, `null` if dismissed.
Future<bool?> showCancelSheet(
  BuildContext context,
  BookingDetailed booking,
) {
  return showModalBottomSheet<bool>(
    context: context,
    shape: AppShape.sheetShape,
    backgroundColor: AppColors.cardWhite,
    isScrollControlled: true,
    builder: (context) => _CancelSheetContent(booking: booking),
  );
}

class _CancelSheetContent extends StatelessWidget {
  final BookingDetailed booking;

  const _CancelSheetContent({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateTimeText = _buildDateTimeText();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Tuhista broneering?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 20),

            // Class details
            _DetailRow(
              icon: Icons.fitness_center_rounded,
              text: booking.className ?? 'Tund',
            ),
            if (dateTimeText.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.access_time_rounded,
                text: dateTimeText,
              ),
            ],
            if (booking.instructorName != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.person_outline_rounded,
                text: booking.instructorName!,
              ),
            ],
            const SizedBox(height: 32),

            // Cancel button (red/coral)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: AppShape.buttonShape,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Tuhista broneering'),
              ),
            ),
            const SizedBox(height: 12),

            // Keep booking button (muted purple/grey)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(null),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                  foregroundColor: AppColors.primaryDark,
                  shape: AppShape.buttonShape,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Hoia broneering'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildDateTimeText() {
    if (booking.classDate == null || booking.classStartTime == null) return '';
    if (booking.classEndTime != null) {
      return DateFormatter.formatDateWithTimeRange(
        booking.classDate!,
        booking.classStartTime!,
        booking.classEndTime!,
      );
    }
    return DateFormatter.formatDateWithTime(
      booking.classDate!,
      booking.classStartTime!,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}
