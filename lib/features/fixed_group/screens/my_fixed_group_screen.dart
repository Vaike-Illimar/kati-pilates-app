import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/providers/fixed_group_provider.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';
import 'package:kati_pilates/shared/widgets/status_badge.dart';

class MyFixedGroupScreen extends ConsumerWidget {
  const MyFixedGroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(groupDetailProvider(groupId));
    final membershipAsync = ref.watch(groupMembershipProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minu p\u00fcsir\u00fchm'),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  'R\u00fchma info laadimine eba\u00f5nnestus',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ref.invalidate(groupDetailProvider(groupId));
                  },
                  child: const Text('Proovi uuesti'),
                ),
              ],
            ),
          ),
        ),
        data: (groupData) {
          final classDef =
              groupData['class_definitions'] as Map<String, dynamic>?;
          final className = classDef?['name'] as String? ??
              groupData['name'] as String? ??
              'Tund';
          final dayOfWeek = classDef?['day_of_week'] as int? ?? 1;
          final startTime = classDef?['start_time'] as String? ?? '09:00';
          final durationMinutes =
              classDef?['duration_minutes'] as int? ?? 60;
          final endTime = _calculateEndTime(startTime, durationMinutes);
          final weekdayName = DateFormatter.weekdayName(dayOfWeek);

          // Instructor info
          final instructorProfile =
              classDef?['profiles'] as Map<String, dynamic>?;
          final instructorName =
              instructorProfile?['full_name'] as String? ?? 'Treener';
          final instructorAvatar =
              instructorProfile?['avatar_url'] as String?;

          // Membership info
          final membership = membershipAsync.value;
          final joinedAt = membership?['joined_at'] != null
              ? DateTime.tryParse(membership!['joined_at'] as String)
              : null;
          final memberId = membership?['id'] as String?;
          final memberStatus = membership?['status'] as String? ?? 'active';

          // Generate upcoming auto-booked dates (next 5 occurrences)
          final upcomingDates = _generateUpcomingDates(dayOfWeek, 5);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class info card with green badge
                _buildClassCard(
                  context,
                  className: className,
                  weekdayName: weekdayName,
                  startTime: startTime,
                  endTime: endTime,
                  instructorName: instructorName,
                  instructorAvatar: instructorAvatar,
                  joinedAt: joinedAt,
                  status: memberStatus,
                ),
                const SizedBox(height: 24),

                // Auto-bookings section
                _buildAutoBookingsSection(context, upcomingDates, startTime),
                const SizedBox(height: 24),

                // Action rows
                _buildActionRows(context, ref, memberId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String className,
    required String weekdayName,
    required String startTime,
    required String endTime,
    required String instructorName,
    String? instructorAvatar,
    DateTime? joinedAt,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Badge row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  className,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(
                label: status == 'paused' ? 'Peatatud' : 'Aktiivne',
                backgroundColor: status == 'paused'
                    ? AppColors.warning
                    : AppColors.success,
                textColor:
                    status == 'paused' ? AppColors.textPrimary : Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Schedule
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Iga $weekdayName \u00b7 ${DateFormatter.formatTime(startTime)}\u2013${DateFormatter.formatTime(endTime)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Instructor
          Row(
            children: [
              AvatarCircle(
                name: instructorName,
                imageUrl: instructorAvatar,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                instructorName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),

          // Member since
          if (joinedAt != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Liige alates ${DateFormatter.monthName(joinedAt.month)} ${joinedAt.year}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoBookingsSection(
    BuildContext context,
    List<DateTime> upcomingDates,
    String startTime,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Automaatsed broneeringud',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < upcomingDates.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormatter.formatDateWithTime(
                            upcomingDates[i],
                            startTime,
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        'Broneeritud',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRows(
    BuildContext context,
    WidgetRef ref,
    String? memberId,
  ) {
    return Column(
      children: [
        // Pause temporarily
        _ActionRow(
          icon: Icons.pause_circle_outline_rounded,
          label: 'Peata ajutiselt',
          color: AppColors.textPrimary,
          onTap: () => _showPauseDialog(context, ref, memberId),
        ),
        const SizedBox(height: 8),
        // Leave group
        _ActionRow(
          icon: Icons.logout_rounded,
          label: 'Lahku r\u00fchmast',
          color: AppColors.error,
          onTap: () => _showLeaveDialog(context, ref, memberId),
        ),
      ],
    );
  }

  void _showPauseDialog(
    BuildContext context,
    WidgetRef ref,
    String? memberId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Peata p\u00fcsir\u00fchm'),
        content: const Text(
          'Sinu automaatsed broneeringud peatatakse ajutiselt. Saad igal ajal j\u00e4tkata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('T\u00fchista'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              if (memberId == null) return;
              try {
                final groupRepo = ref.read(fixedGroupRepositoryProvider);
                await groupRepo.pauseMembership(memberId);
                ref.invalidate(groupMembershipProvider(groupId));
                ref.invalidate(myGroupsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('P\u00fcsir\u00fchm peatatud'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viga: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Peata'),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(
    BuildContext context,
    WidgetRef ref,
    String? memberId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lahku r\u00fchmast'),
        content: const Text(
          'Kas oled kindel, et soovid r\u00fchmast lahkuda? Sinu automaatsed broneeringud t\u00fchistatakse ja koht vabastatakse.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('T\u00fchista'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              if (memberId == null) return;
              try {
                final groupRepo = ref.read(fixedGroupRepositoryProvider);
                await groupRepo.leaveGroup(memberId);
                ref.invalidate(myGroupsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Oled r\u00fchmast lahkunud'),
                    ),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viga: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Lahku'),
          ),
        ],
      ),
    );
  }

  /// Generate next N occurrences of a specific weekday from today.
  List<DateTime> _generateUpcomingDates(int dayOfWeek, int count) {
    final now = DateTime.now();
    final dates = <DateTime>[];
    var current = DateTime(now.year, now.month, now.day);

    // Find the next occurrence of the target weekday
    while (current.weekday != dayOfWeek) {
      current = current.add(const Duration(days: 1));
    }

    // If today is the target day but it's already past, skip to next week
    if (current.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
      // Include today's occurrence
    }

    for (int i = 0; i < count; i++) {
      dates.add(current);
      current = current.add(const Duration(days: 7));
    }

    return dates;
  }

  String _calculateEndTime(String startTime, int durationMinutes) {
    final parts = startTime.split(':');
    final startHour = int.tryParse(parts[0]) ?? 9;
    final startMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final totalMinutes = startHour * 60 + startMinute + durationMinutes;
    final endHour = (totalMinutes ~/ 60) % 24;
    final endMinute = totalMinutes % 60;
    return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(AppShape.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
