import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/studio.dart';
import 'package:kati_pilates/shared/widgets/empty_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final studiosListProvider = FutureProvider.autoDispose<List<Studio>>((ref) async {
  final data = await Supabase.instance.client
      .from('studios')
      .select()
      .order('name');
  return data.map((json) => Studio.fromJson(json)).toList();
});

class StudiosScreen extends ConsumerWidget {
  const StudiosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studiosAsync = ref.watch(studiosListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stuudiod'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Lisa stuudio',
            onPressed: () => _showStudioDialog(context, ref, null),
          ),
        ],
      ),
      body: studiosAsync.when(
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
                onPressed: () => ref.invalidate(studiosListProvider),
                child: const Text('Proovi uuesti'),
              ),
            ],
          ),
        ),
        data: (studios) {
          if (studios.isEmpty) {
            return EmptyState(
              icon: Icons.location_city_outlined,
              title: 'Stuudioid pole',
              subtitle: 'Lisa esimene stuudio',
              actionLabel: 'Lisa stuudio',
              onAction: () => _showStudioDialog(context, ref, null),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(studiosListProvider);
              await ref.read(studiosListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              itemCount: studios.length,
              itemBuilder: (context, index) {
                final studio = studios[index];
                return _StudioCard(
                  studio: studio,
                  onEdit: () => _showStudioDialog(context, ref, studio),
                  onDelete: () => _confirmDelete(context, ref, studio),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showStudioDialog(
    BuildContext context,
    WidgetRef ref,
    Studio? existing,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => _StudioDialog(
        existing: existing,
        onSave: (name, address, capacity) async {
          try {
            if (existing != null) {
              await Supabase.instance.client
                  .from('studios')
                  .update({'name': name, 'address': address, 'capacity': capacity})
                  .eq('id', existing.id);
            } else {
              await Supabase.instance.client
                  .from('studios')
                  .insert({'name': name, 'address': address, 'capacity': capacity});
            }
            ref.invalidate(studiosListProvider);
            if (ctx.mounted) Navigator.of(ctx).pop();
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Salvestamine ebaõnnestus: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Studio studio,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.cardRadius)),
        title: const Text('Kustuta stuudio'),
        content: Text(
            'Kas soovid kustutada stuudio "${studio.name}"? '
            'Olemasolevaid tunde see ei mõjuta.'),
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
      await Supabase.instance.client
          .from('studios')
          .delete()
          .eq('id', studio.id);
      ref.invalidate(studiosListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stuudio kustutatud')),
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

class _StudioCard extends StatelessWidget {
  final Studio studio;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudioCard({
    required this.studio,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_on_outlined,
              color: AppColors.primaryDark),
        ),
        title: Text(studio.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (studio.address != null) Text(studio.address!),
            Text('Maht: ${studio.capacity} kohta',
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded,
              size: 20, color: AppColors.textSecondary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShape.cardRadius)),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
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
      ),
    );
  }
}

class _StudioDialog extends StatefulWidget {
  final Studio? existing;
  final Future<void> Function(String name, String? address, int capacity)
      onSave;

  const _StudioDialog({this.existing, required this.onSave});

  @override
  State<_StudioDialog> createState() => _StudioDialogState();
}

class _StudioDialogState extends State<_StudioDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _capacityController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _addressController =
        TextEditingController(text: widget.existing?.address ?? '');
    _capacityController =
        TextEditingController(text: widget.existing?.capacity.toString() ?? '10');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.cardRadius)),
      title: Text(
          widget.existing != null ? 'Muuda stuudiot' : 'Lisa stuudio'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nimi *'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Sisesta stuudio nimi'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Aadress'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(labelText: 'Maht (kohti) *'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Sisesta maht';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tühista'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Salvesta'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _nameController.text.trim(),
        _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        int.parse(_capacityController.text.trim()),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
