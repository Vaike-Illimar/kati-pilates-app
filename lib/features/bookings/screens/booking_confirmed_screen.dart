import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/routes.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';

class BookingConfirmedScreen extends ConsumerWidget {
  /// The booking details to display. Passed via GoRouter extra.
  final BookingDetailed? booking;

  const BookingConfirmedScreen({super.key, this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // Checkmark icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 44,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Broneering kinnitatud!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    const SizedBox(height: 32),

                    // Class details card
                    if (booking != null) _ClassDetailsCard(booking: booking!),

                    // Fixed group upsell (optional)
                    // Shown only if the class info suggests a fixed group is available
                    if (booking != null) ...[
                      const SizedBox(height: 24),
                      _FixedGroupUpsell(booking: booking!),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.go(RoutePaths.bookings),
                      child: const Text('Vaata broneeringuid'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.go(RoutePaths.schedule),
                      child: const Text('Tagasi tunniplaani'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Class details card
// ---------------------------------------------------------------------------
class _ClassDetailsCard extends StatelessWidget {
  final BookingDetailed booking;

  const _ClassDetailsCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateTimeText = _buildDateTimeText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class name
          Text(
            booking.className ?? 'Tund',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),

          // Date & time
          if (dateTimeText.isNotEmpty)
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              text: dateTimeText,
            ),

          // Time range
          if (booking.classStartTime != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.access_time_rounded,
              text: booking.classEndTime != null
                  ? '${DateFormatter.formatTime(booking.classStartTime!)}'
                      '\u2013${DateFormatter.formatTime(booking.classEndTime!)}'
                  : DateFormatter.formatTime(booking.classStartTime!),
            ),
          ],

          // Instructor
          if (booking.instructorName != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              text: booking.instructorName!,
            ),
          ],

          // Studio
          if (booking.studioName != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: booking.studioName!,
            ),
          ],
        ],
      ),
    );
  }

  String _buildDateTimeText() {
    if (booking.classDate == null) return '';
    return DateFormatter.formatDate(booking.classDate!);
  }
}

// ---------------------------------------------------------------------------
// Fixed group upsell section
// ---------------------------------------------------------------------------
class _FixedGroupUpsell extends StatelessWidget {
  final BookingDetailed booking;

  const _FixedGroupUpsell({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group_rounded,
                size: 20,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 8),
              Text(
                'Tee sellest pusikoht?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Liitu pusiruhaga ja su koht on iganadalaselt broneeritud. '
            'Ei pea enam muretsema, et kohad saavad otsa!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to fixed group detail if available
                // For now, a placeholder action
              },
              child: const Text('Liitu pusiruhmaga'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row helper
// ---------------------------------------------------------------------------
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

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
