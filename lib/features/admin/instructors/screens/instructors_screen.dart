import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/profile.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';
import 'package:kati_pilates/shared/widgets/empty_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final instructorsProvider =
    FutureProvider.autoDispose<List<Profile>>((ref) async {
  final data = await Supabase.instance.client
      .from('profiles')
      .select()
      .inFilter('role', ['instructor', 'admin'])
      .order('full_name');
  return data.map((json) => Profile.fromJson(json)).toList();
});

final allClientsProvider =
    FutureProvider.autoDispose<List<Profile>>((ref) async {
  final data = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('role', 'client')
      .order('full_name');
  return data.map((json) => Profile.fromJson(json)).toList();
});

class InstructorsScreen extends ConsumerWidget {
  const InstructorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorsAsync = ref.watch(instructorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treenerid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Lisa treener',
            onPressed: () => _showAssignInstructorDialog(context, ref),
          ),
        ],
      ),
      body: instructorsAsync.when(
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
                onPressed: () => ref.invalidate(instructorsProvider),
                child: const Text('Proovi uuesti'),
              ),
            ],
          ),
        ),
        data: (instructors) {
          if (instructors.isEmpty) {
            return EmptyState(
              icon: Icons.person_outline_rounded,
              title: 'Treenereid pole',
              subtitle: 'Määra treenerirolli olemasolevale kasutajale',
              actionLabel: 'Lisa treener',
              onAction: () => _showAssignInstructorDialog(context, ref),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(instructorsProvider);
              await ref.read(instructorsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              itemCount: instructors.length,
              itemBuilder: (context, index) {
                final instructor = instructors[index];
                return _InstructorCard(
                  profile: instructor,
                  onRemove: instructor.role == UserRole.instructor
                      ? () => _confirmRemoveRole(context, ref, instructor)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAssignInstructorDialog(
      BuildContext context, WidgetRef ref) async {
    final clients = await ref.read(allClientsProvider.future);

    if (!context.mounted) return;

    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pole kliente, kellele treenerirolli määrata')),
      );
      return;
    }

    Profile? selectedClient;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShape.cardRadius)),
          title: const Text('Määra treenerroll'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vali kasutaja, kellele määrata treenerroll:',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Profile>(
                value: selectedClient,
                decoration:
                    const InputDecoration(labelText: 'Kasutaja'),
                isExpanded: true,
                items: clients
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            '${c.fullName} (${c.email})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedClient = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tühista'),
            ),
            FilledButton(
              onPressed: selectedClient == null
                  ? null
                  : () async {
                      try {
                        await Supabase.instance.client
                            .from('profiles')
                            .update({'role': 'instructor'})
                            .eq('id', selectedClient!.id);
                        ref.invalidate(instructorsProvider);
                        ref.invalidate(allClientsProvider);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${selectedClient!.fullName} on nüüd treener',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Rolli muutmine ebaõnnestus: $e')),
                          );
                        }
                      }
                    },
              child: const Text('Määra treenerroll'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemoveRole(
    BuildContext context,
    WidgetRef ref,
    Profile instructor,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.cardRadius)),
        title: const Text('Eemalda treenerroll'),
        content: Text(
          'Kas soovid eemaldada ${instructor.fullName} treenerrolli? '
          'Kasutaja muutub tavalise kliendi rolli.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tühista'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eemalda roll'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'role': 'client'})
          .eq('id', instructor.id);
      ref.invalidate(instructorsProvider);
      ref.invalidate(allClientsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${instructor.fullName} roll eemaldatud')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rolli eemaldamine ebaõnnestus: $e')),
        );
      }
    }
  }
}

class _InstructorCard extends StatelessWidget {
  final Profile profile;
  final VoidCallback? onRemove;

  const _InstructorCard({required this.profile, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isAdmin = profile.role == UserRole.admin;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: AvatarCircle(
          name: profile.fullName,
          imageUrl: profile.avatarUrl,
          size: 44,
        ),
        title: Row(
          children: [
            Text(profile.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (isAdmin) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(profile.email,
            style: const TextStyle(color: AppColors.textSecondary)),
        trailing: onRemove != null
            ? IconButton(
                icon: const Icon(Icons.person_remove_outlined,
                    color: AppColors.error, size: 20),
                tooltip: 'Eemalda treenerroll',
                onPressed: onRemove,
              )
            : null,
      ),
    );
  }
}
