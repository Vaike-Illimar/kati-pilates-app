import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';

/// Shows a bottom sheet warning about late cancellation penalties.
/// Returns `true` if the user confirmed cancellation anyway, `null` if dismissed.
Future<bool?> showLateCancelWarning(
  BuildContext context,
  BookingDetailed booking,
) {
  return showModalBottomSheet<bool>(
    context: context,
    shape: AppShape.sheetShape,
    backgroundColor: AppColors.cardWhite,
    isScrollControlled: true,
    builder: (context) => _LateCancelContent(booking: booking),
  );
}

class _LateCancelContent extends StatelessWidget {
  final BookingDetailed booking;

  const _LateCancelContent({required this.booking});

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

            // Warning icon + title
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'Hiline tuhistamine',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Class details
            _DetailRow(
              icon: Icons.fitness_center_rounded,
              text: booking.className ?? 'Tund',
            ),
            if (booking.level != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.signal_cellular_alt_rounded,
                text: booking.level!,
              ),
            ],
            if (dateTimeText.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.access_time_rounded,
                text: dateTimeText,
              ),
            ],
            const SizedBox(height: 20),

            // Warning box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppShape.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tund algab vahem kui 2 tunni parast.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tuhistamisel arvestatakse 1 sessioonikrediti automaatselt '
                    'su kaardilt maha. Tundi ei saa tagastada.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info line
            Row(
              children: [
                Icon(
                  Icons.credit_card_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  '1 sessioon arvestatakse kaardilt maha',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cancel anyway button (red)
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
                child: const Text('Tuhistan igal juhul'),
              ),
            ),
            const SizedBox(height: 12),

            // Keep booking button (muted)
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
