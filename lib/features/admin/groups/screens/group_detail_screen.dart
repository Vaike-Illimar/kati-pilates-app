import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/providers/fixed_group_provider.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';
import 'package:kati_pilates/shared/widgets/status_badge.dart';
import 'package:kati_pilates/features/admin/groups/widgets/member_actions_sheet.dart';

/// Provider for fetching group members (admin view).
final _adminGroupMembersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, groupId) async {
  final groupRepo = ref.watch(fixedGroupRepositoryProvider);
  return groupRepo.getGroupMembers(groupId);
});

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(groupDetailProvider(groupId));
    final membersAsync = ref.watch(_adminGroupMembersProvider(groupId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
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
                  'Rühma info laadimine ebaõnnestus',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ref.invalidate(groupDetailProvider(groupId));
                    ref.invalidate(_adminGroupMembersProvider(groupId));
                  },
                  child: const Text('Proovi uuesti'),
                ),
              ],
            ),
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
        final durationMinutes = classDef?['duration_minutes'] as int? ?? 60;
        final endTime = _calculateEndTime(startTime, durationMinutes);
        final weekdayName = DateFormatter.weekdayName(dayOfWeek);
        final weekdayShort = DateFormatter.weekdayShort(dayOfWeek);
        final maxMembers = groupData['max_members'] as int? ?? 10;
        final isActive = groupData['is_active'] as bool? ?? true;

        return Scaffold(
          appBar: AppBar(
            title: Text(className),
          ),
          body: membersAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Liikmete laadimine ebaõnnestus',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () =>
                        ref.invalidate(_adminGroupMembersProvider(groupId)),
                    child: const Text('Proovi uuesti'),
                  ),
                ],
              ),
            ),
            data: (members) {
              // Filter to active/paused/invited members
              final activeMembers = members
                  .where((m) =>
                      m['status'] == 'active' ||
                      m['status'] == 'paused' ||
                      m['status'] == 'invited')
                  .toList();
              final memberCount = activeMembers.length;

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        ref.invalidate(groupDetailProvider(groupId));
                        ref.invalidate(_adminGroupMembersProvider(groupId));
                        await ref
                            .read(_adminGroupMembersProvider(groupId).future);
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        children: [
                          // Info header card
                          _buildInfoHeader(
                            context,
                            weekdayName: weekdayName,
                            startTime: startTime,
                            endTime: endTime,
                            isActive: isActive,
                            memberCount: memberCount,
                            maxMembers: maxMembers,
                          ),
                          const SizedBox(height: 24),

                          // Members section header
                          Text(
                            'Liikmed ($memberCount)',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),

                          // Member list
                          if (activeMembers.isEmpty)
                            _buildEmptyMembers(context)
                          else
                            ...activeMembers.map((member) => _MemberTile(
                                  memberData: member,
                                  onTap: () => _onMemberTap(
                                    context,
                                    ref,
                                    member,
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),

                  // Bottom button
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            context.push(
                              '/admin/groups/$groupId/add-member',
                              extra: {
                                'groupName': className,
                                'weekdayShort': weekdayShort,
                                'startTime': startTime,
                              },
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Lisa liige'),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoHeader(
    BuildContext context, {
    required String weekdayName,
    required String startTime,
    required String endTime,
    required bool isActive,
    required int memberCount,
    required int maxMembers,
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
          // Schedule row
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Iga $weekdayName',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Time row
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${DateFormatter.formatTime(startTime)} \u2014 ${DateFormatter.formatTime(endTime)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(),
              StatusBadge(
                label: isActive ? 'Aktiivne' : 'Mitteaktiivne',
                backgroundColor:
                    isActive ? AppColors.success : AppColors.textSecondary,
                textColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Participant count
          Text(
            'Osalejaid $memberCount / $maxMembers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMembers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 40,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Rühmas pole veel liikmeid',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMemberTap(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> memberData,
  ) async {
    final result = await showMemberActionsSheet(context, memberData, ref);
    if (result == true && context.mounted) {
      ref.invalidate(groupDetailProvider(groupId));
      ref.invalidate(_adminGroupMembersProvider(groupId));
    }
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

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.memberData,
    required this.onTap,
  });

  final Map<String, dynamic> memberData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final profile = memberData['profiles'] as Map<String, dynamic>?;
    final fullName = profile?['full_name'] as String? ?? 'Kasutaja';
    final email = profile?['email'] as String? ?? '';
    final status = memberData['status'] as String? ?? 'active';
    final isPaused = status == 'paused';

    // Parse join date
    final joinedAtRaw = memberData['joined_at'] as String?;
    final joinedAt =
        joinedAtRaw != null ? DateTime.tryParse(joinedAtRaw) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppShape.cardRadius),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                AvatarCircle(name: fullName, size: 42),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPaused) ...[
                            const SizedBox(width: 8),
                            const StatusBadge(
                              label: 'Peatatud',
                              backgroundColor: AppColors.warning,
                              textColor: AppColors.textPrimary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        joinedAt != null
                            ? 'Liige alates ${DateFormatter.formatDate(joinedAt)}'
                            : email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
