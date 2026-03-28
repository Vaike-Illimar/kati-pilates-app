import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/class_instance.dart';
import 'package:kati_pilates/providers/schedule_provider.dart';
import 'package:kati_pilates/repositories/class_repository.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/empty_state.dart';
import 'package:kati_pilates/shared/widgets/weekday_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin: cancel a class instance (set is_cancelled = true or false)
final _adminClassRepoProvider = Provider<ClassRepository>((ref) {
  return ClassRepository(Supabase.instance.client);
});

class AdminCalendarScreen extends ConsumerWidget {
  const AdminCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final scheduleAsync = ref.watch(scheduleProvider(selectedDate));

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(scheduleProvider(selectedDate));
            await ref.read(scheduleProvider(selectedDate).future);
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kalender',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tunniplaan ja haldus',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      // Generate schedule button
                      FilledButton.icon(
                        onPressed: () =>
                            _generateSchedule(context, ref),
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Genereeri'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Weekday selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: WeekdaySelector(
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      ref.read(selectedDateProvider.notifier).setDate(date);
                    },
                  ),
                ),
              ),

              // Date header + manage link
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatFullEstonianDate(selectedDate),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            context.push('/admin/calendar/class-definitions'),
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text('Tunnid'),
                      ),
                    ],
                  ),
                ),
              ),

              // Class instance list
              scheduleAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _AdminErrorState(
                      onRetry: () =>
                          ref.invalidate(scheduleProvider(selectedDate)),
                    ),
                  ),
                ),
                data: (classes) {
                  if (classes.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.event_busy_rounded,
                        title: 'Täna tunde pole',
                        subtitle: 'Genereeri tunniplaan või lisa uus tund',
                        actionLabel: 'Genereeri',
                        onAction: () => _generateSchedule(context, ref),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    sliver: SliverList.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final ci = classes[index];
                        return _AdminClassCard(
                          classInstance: ci,
                          onTap: () => context.push(
                            '/admin/calendar/instance/${ci.id}',
                          ),
                          onCancelToggle: () =>
                              _toggleCancel(context, ref, ci, selectedDate),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFullEstonianDate(DateTime date) {
    final weekdayName = EstonianWeekday.fullFor(date.weekday);
    final monthName = DateFormatter.monthName(date.month);
    return '$weekdayName, ${date.day}. $monthName';
  }

  Future<void> _generateSchedule(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.cardRadius)),
        title: const Text('Genereeri järgmise nädala tunniplaan'),
        content: const Text(
          'See loob järgmise nädala tunnid kõigi aktiivsete tunnidefinitsioonide põhjal. Olemasolevaid tunde ei muudeta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tühista'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Genereeri'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await Supabase.instance.client.functions.invoke(
        'generate-instances',
        body: {},
      );

      final selectedDate = ref.read(selectedDateProvider);
      ref.invalidate(scheduleProvider(selectedDate));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tunniplaan genereeritud edukalt!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Genereerimine ebaõnnestus: $e')),
        );
      }
    }
  }

  Future<void> _toggleCancel(
    BuildContext context,
    WidgetRef ref,
    ClassInstanceWithDetails ci,
    DateTime selectedDate,
  ) async {
    final isCancelling = !ci.isCancelled;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.cardRadius)),
        title: Text(isCancelling ? 'Tühistage tund' : 'Taasta tund'),
        content: Text(
          isCancelling
              ? 'Kas soovite selle tunni tühistada? Kõik broneerijad teavitatakse.'
              : 'Kas soovite selle tunni taastada?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tühista'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: isCancelling
                ? FilledButton.styleFrom(
                    backgroundColor: AppColors.error)
                : null,
            child: Text(isCancelling ? 'Tühista tund' : 'Taasta'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await Supabase.instance.client
          .from('class_instances')
          .update({'is_cancelled': isCancelling})
          .eq('id', ci.id);

      ref.invalidate(scheduleProvider(selectedDate));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCancelling ? 'Tund tühistatud' : 'Tund taastatud',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tegevus ebaõnnestus: $e')),
        );
      }
    }
  }
}

class _AdminClassCard extends StatelessWidget {
  final ClassInstanceWithDetails classInstance;
  final VoidCallback onTap;
  final VoidCallback onCancelToggle;

  const _AdminClassCard({
    required this.classInstance,
    required this.onTap,
    required this.onCancelToggle,
  });

  @override
  Widget build(BuildContext context) {
    final ci = classInstance;
    final isCancelled = ci.isCancelled;
    final isFull = ci.availableSpots <= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isCancelled
            ? AppColors.textSecondary.withValues(alpha: 0.08)
            : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
          color: isCancelled
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Time column
              SizedBox(
                width: 52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatTime(ci.startTime),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isCancelled
                                ? AppColors.textSecondary
                                : AppColors.primary,
                          ),
                    ),
                    Text(
                      DateFormatter.formatTime(ci.endTime),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Main info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ci.className ?? 'Nimetu tund',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      decoration: isCancelled
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                          ),
                        ),
                        if (isCancelled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Tühistatud',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (ci.instructorName != null) ...[
                          const Icon(Icons.person_outline_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            ci.instructorName!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 10),
                        ],
                        const Icon(Icons.people_outline_rounded,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${ci.confirmedCount}/${ci.maxParticipants}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    isFull ? AppColors.error : AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (ci.waitlistCount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '+${ci.waitlistCount} ootel',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.warning),
                          ),
                        ],
                      ],
                    ),
                    if (ci.studioName != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            ci.studioName!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Action menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.textSecondary, size: 20),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppShape.cardRadius)),
                onSelected: (value) {
                  if (value == 'cancel') onCancelToggle();
                  if (value == 'detail') onTap();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Vaata detaile'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(
                          isCancelled
                              ? Icons.restore_rounded
                              : Icons.cancel_outlined,
                          size: 18,
                          color: isCancelled
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isCancelled ? 'Taasta tund' : 'Tühista tund',
                          style: TextStyle(
                            color: isCancelled
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _AdminErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Icon(Icons.error_outline_rounded,
            size: 48, color: AppColors.error.withValues(alpha: 0.7)),
        const SizedBox(height: 12),
        Text(
          'Andmete laadimine ebaõnnestus',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onRetry, child: const Text('Proovi uuesti')),
      ],
    );
  }
}
