import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/providers/fixed_group_provider.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';
import 'package:kati_pilates/shared/widgets/status_badge.dart';

class FixedGroupInvitationScreen extends ConsumerStatefulWidget {
  const FixedGroupInvitationScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<FixedGroupInvitationScreen> createState() =>
      _FixedGroupInvitationScreenState();
}

class _FixedGroupInvitationScreenState
    extends ConsumerState<FixedGroupInvitationScreen> {
  bool _isAccepting = false;
  bool _isDeclining = false;

  bool get _isLoading => _isAccepting || _isDeclining;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(groupDetailProvider(widget.groupId));
    final membershipAsync = ref.watch(groupMembershipProvider(widget.groupId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('P\u00fcsir\u00fchma kutse'),
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
                  'Kutse laadimine eba\u00f5nnestus',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ref.invalidate(groupDetailProvider(widget.groupId));
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
          final durationMinutes = classDef?['duration_minutes'] as int? ?? 60;
          final endTime = _calculateEndTime(startTime, durationMinutes);
          final weekdayName = DateFormatter.weekdayName(dayOfWeek);

          // Instructor info from nested profiles join
          final instructorProfile =
              classDef?['profiles'] as Map<String, dynamic>?;
          final instructorName =
              instructorProfile?['full_name'] as String? ?? 'Treener';
          final instructorAvatar =
              instructorProfile?['avatar_url'] as String?;

          final memberId = membershipAsync.value?['id'] as String?;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Purple badge
                      const StatusBadge(
                        label: 'Kutse p\u00fcsir\u00fchma',
                        backgroundColor: AppColors.primaryDark,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Class name (large, bold)
                      Text(
                        className,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),

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
                                .bodyLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Instructor row
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius:
                              BorderRadius.circular(AppShape.cardRadius),
                          border: Border.all(
                            color:
                                AppColors.primaryLight.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            AvatarCircle(
                              name: instructorName,
                              imageUrl: instructorAvatar,
                              size: 44,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    instructorName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pilates treener',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info box "Mis on p\u00fcsir\u00fchm?"
                      _buildInfoBox(context),
                      const SizedBox(height: 24),

                      // Benefits section
                      _buildBenefitsSection(context),
                    ],
                  ),
                ),
              ),

              // Bottom action buttons
              _buildBottomButtons(context, memberId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 22,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis on p\u00fcsir\u00fchm?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sinu koht on automaatselt reserveeritud iga n\u00e4dal \u2014 broneerida ei pea.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eelised',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _BenefitItem(
          icon: Icons.check_circle_rounded,
          title: 'Koht alati reserveeritud',
          subtitle:
              'Sinu koht on tagatud igal n\u00e4dalal automaatselt',
        ),
        const SizedBox(height: 12),
        _BenefitItem(
          icon: Icons.event_available_rounded,
          title: 'Ei pea broneerima',
          subtitle:
              'Unusta k\u00e4sitsi broneerimine \u2014 toimub automaatselt',
        ),
        const SizedBox(height: 12),
        _BenefitItem(
          icon: Icons.exit_to_app_rounded,
          title: 'Lihtne lahkuda v\u00f5i peatada',
          subtitle:
              'Saad igal ajal r\u00fchmast lahkuda v\u00f5i ajutiselt peatada',
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context, String? memberId) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  _isLoading || memberId == null
                      ? null
                      : () => _handleAccept(context, memberId),
              child: _isAccepting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Liitu p\u00fcsir\u00fchmaga'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed:
                  _isLoading || memberId == null
                      ? null
                      : () => _handleDecline(context, memberId),
              child: _isDeclining
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text('Keeldu'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAccept(BuildContext ctx, String memberId) async {
    setState(() => _isAccepting = true);
    try {
      final groupRepo = ref.read(fixedGroupRepositoryProvider);
      await groupRepo.respondToInvitation(memberId: memberId, accept: true);

      ref.invalidate(pendingInvitationsProvider);
      ref.invalidate(myGroupsProvider);
      ref.invalidate(groupMembershipProvider(widget.groupId));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oled n\u00fc\u00fcd p\u00fcsir\u00fchma liige!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/schedule/fixed-group/${widget.groupId}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Viga: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  Future<void> _handleDecline(BuildContext ctx, String memberId) async {
    setState(() => _isDeclining = true);
    try {
      final groupRepo = ref.read(fixedGroupRepositoryProvider);
      await groupRepo.respondToInvitation(memberId: memberId, accept: false);

      ref.invalidate(pendingInvitationsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kutse keeldutud'),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Viga: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeclining = false);
    }
  }

  /// Calculate end time from start time + duration in minutes.
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

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
