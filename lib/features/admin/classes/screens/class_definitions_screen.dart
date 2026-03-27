import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/class_definition.dart';
import 'package:kati_pilates/providers/schedule_provider.dart';
import 'package:kati_pilates/shared/widgets/empty_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final classDefinitionsProvider =
    FutureProvider.autoDispose<List<ClassDefinition>>((ref) async {
  final repo = ref.watch(classRepositoryProvider);
  return repo.getClassDefinitions();
});

class ClassDefinitionsScreen extends ConsumerWidget {
  const ClassDefinitionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final definitionsAsync = ref.watch(classDefinitionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Tunnidefinitsioonid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Lisa uus tunnidefinitsioon',
            onPressed: () => context.push('/admin/calendar/class-definitions/new'),
          ),
        ],
      ),
      body: definitionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Laadimine ebaõnnestus',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(classDefinitionsProvider),
                child: const Text('Proovi uuesti'),
              ),
            ],
          ),
        ),
        data: (definitions) {
          if (definitions.isEmpty) {
            return EmptyState(
              icon: Icons.class_outlined,
              title: 'Tunnidefinitsioone pole',
              subtitle: 'Lisa esimene tund, et alustada tunniplaani genereerimist',
              actionLabel: 'Lisa tund',
              onAction: () =>
                  context.push('/admin/calendar/class-definitions/new'),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(classDefinitionsProvider);
              await ref.read(classDefinitionsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              itemCount: definitions.length,
              itemBuilder: (context, index) {
                final def = definitions[index];
                return _ClassDefinitionCard(
                  definition: def,
                  onTap: () => context.push(
                    '/admin/calendar/class-definitions/${def.id}',
                    extra: def,
                  ),
                  onDelete: () => _confirmDelete(context, ref, def),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ClassDefinition def,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.cardRadius)),
        title: const Text('Kustuta tunnidefinitsioon'),
        content: Text(
          'Kas oled kindel, et soovid kustutada "${def.name}"? '
          'Olemasolevaid tunnieksemplare see ei mõjuta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tühista'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Kustuta'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      // Deactivate instead of hard delete to preserve history
      await Supabase.instance.client
          .from('class_definitions')
          .update({'is_active': false})
          .eq('id', def.id);

      ref.invalidate(classDefinitionsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tunnidefinitsioon kustutatud')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kustutamine ebaõnnestus: $e')),
        );
      }
    }
  }
}

class _ClassDefinitionCard extends StatelessWidget {
  final ClassDefinition definition;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ClassDefinitionCard({
    required this.definition,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final def = definition;
    final weekdayName = _weekdayName(def.dayOfWeek);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Day + time indicator
              Container(
                width: 56,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      weekdayName.substring(0, 2).toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      def.startTime.substring(0, 5),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${def.durationMinutes} min',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.people_outline_rounded,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          'Max ${def.maxParticipants}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 10),
                        _LevelBadge(level: def.level),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 20, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppShape.cardRadius)),
                onSelected: (value) {
                  if (value == 'edit') onTap();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Muuda'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 10),
                        Text('Kustuta',
                            style: TextStyle(color: AppColors.error)),
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

  String _weekdayName(int day) {
    const names = [
      'Esmaspäev',
      'Teisipäev',
      'Kolmapäev',
      'Neljapäev',
      'Reede',
      'Laupäev',
      'Pühapäev',
    ];
    return names[(day - 1).clamp(0, 6)];
  }
}

class _LevelBadge extends StatelessWidget {
  final ClassLevel level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (level) {
      ClassLevel.algaja => ('Algaja', AppColors.success),
      ClassLevel.kesktase => ('Kesktase', AppColors.warning),
      ClassLevel.koik => ('Kõik', AppColors.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
