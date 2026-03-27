import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/fixed_group.dart';
import 'package:kati_pilates/providers/fixed_group_provider.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/status_badge.dart';

/// Provider that fetches all groups with their member counts.
final _adminAllGroupsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final groupRepo = ref.watch(fixedGroupRepositoryProvider);
  final groups = await groupRepo.getAllGroups();

  final result = <Map<String, dynamic>>[];
  for (final group in groups) {
    final details = await groupRepo.getGroupWithDetails(group.id);
    final members = await groupRepo.getGroupMembers(group.id);
    // Count only active + paused members (not declined/removed)
    final activeMembers = members
        .where((m) =>
            m['status'] == 'active' ||
            m['status'] == 'paused' ||
            m['status'] == 'invited')
        .toList();
    result.add({
      'group': group,
      'details': details,
      'memberCount': activeMembers.length,
    });
  }
  return result;
});

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(_adminAllGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Püsirühmad'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rühma lisamine tulekul')),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Lisa rühm'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: groupsAsync.when(
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
                  'Rühmade laadimine ebaõnnestus',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(_adminAllGroupsProvider),
                  child: const Text('Proovi uuesti'),
                ),
              ],
            ),
          ),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 48,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Püsirühmi pole veel loodud',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(_adminAllGroupsProvider);
              // Wait for the provider to re-fetch
              await ref.read(_adminAllGroupsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final item = groups[index];
                final group = item['group'] as FixedGroup;
                final details = item['details'] as Map<String, dynamic>;
                final memberCount = item['memberCount'] as int;

                return _GroupCard(
                  group: group,
                  details: details,
                  memberCount: memberCount,
                  onTap: () {
                    context.push('/admin/groups/${group.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.details,
    required this.memberCount,
    required this.onTap,
  });

  final FixedGroup group;
  final Map<String, dynamic> details;
  final int memberCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final classDef = details['class_definitions'] as Map<String, dynamic>?;
    final className =
        classDef?['name'] as String? ?? details['name'] as String? ?? 'Tund';
    final dayOfWeek = classDef?['day_of_week'] as int? ?? 1;
    final startTime = classDef?['start_time'] as String? ?? '09:00';
    final durationMinutes = classDef?['duration_minutes'] as int? ?? 60;
    final endTime = _calculateEndTime(startTime, durationMinutes);

    final weekdayName = DateFormatter.weekdayName(dayOfWeek);
    final isFull = memberCount >= group.maxMembers;
    final progress =
        group.maxMembers > 0 ? memberCount / group.maxMembers : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppShape.cardRadius),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class name
                      Text(
                        className,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 6),

                      // Schedule
                      Text(
                        'Iga $weekdayName \u00b7 ${DateFormatter.formatTime(startTime)}\u2013${DateFormatter.formatTime(endTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Member count progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor:
                                    AppColors.primaryLight.withValues(alpha: 0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isFull ? AppColors.error : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$memberCount / ${group.maxMembers} liiget',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                      if (isFull) ...[
                        const SizedBox(height: 8),
                        const StatusBadge(
                          label: 'Täis',
                          backgroundColor: AppColors.error,
                          textColor: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
