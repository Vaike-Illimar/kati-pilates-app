import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/class_definition.dart';
import 'package:kati_pilates/models/profile.dart';
import 'package:kati_pilates/models/studio.dart';
import 'package:kati_pilates/features/admin/classes/screens/class_definitions_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _studiosProvider = FutureProvider.autoDispose<List<Studio>>((ref) async {
  final data = await Supabase.instance.client
      .from('studios')
      .select()
      .order('name');
  return data.map((json) => Studio.fromJson(json)).toList();
});

final _instructorsProvider =
    FutureProvider.autoDispose<List<Profile>>((ref) async {
  final data = await Supabase.instance.client
      .from('profiles')
      .select()
      .inFilter('role', ['instructor', 'admin'])
      .order('full_name');
  return data.map((json) => Profile.fromJson(json)).toList();
});

class EditClassDefinitionScreen extends ConsumerStatefulWidget {
  final ClassDefinition? existing;

  const EditClassDefinitionScreen({super.key, this.existing});

  @override
  ConsumerState<EditClassDefinitionScreen> createState() =>
      _EditClassDefinitionScreenState();
}

class _EditClassDefinitionScreenState
    extends ConsumerState<EditClassDefinitionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _maxParticipantsController;
  late final TextEditingController _startTimeController;

  ClassLevel _level = ClassLevel.koik;
  int _dayOfWeek = 1;
  String? _selectedStudioId;
  String? _selectedInstructorId;
  bool _isSaving = false;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _descriptionController =
        TextEditingController(text: e?.description ?? '');
    _durationController =
        TextEditingController(text: e?.durationMinutes.toString() ?? '60');
    _maxParticipantsController =
        TextEditingController(text: e?.maxParticipants.toString() ?? '10');
    _startTimeController =
        TextEditingController(text: e?.startTime.substring(0, 5) ?? '09:00');
    _level = e?.level ?? ClassLevel.koik;
    _dayOfWeek = e?.dayOfWeek ?? 1;
    _selectedStudioId = e?.studioId;
    _selectedInstructorId = e?.instructorId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    _startTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studiosAsync = ref.watch(_studiosProvider);
    final instructorsAsync = ref.watch(_instructorsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(isEditing ? 'Muuda tunnidefinitsiooni' : 'Uus tunnidefinitsioon'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tunni nimi *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Sisesta tunni nimi' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Kirjeldus'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Level
              _SectionLabel(label: 'Tase'),
              const SizedBox(height: 8),
              SegmentedButton<ClassLevel>(
                segments: const [
                  ButtonSegment(
                      value: ClassLevel.algaja, label: Text('Algaja')),
                  ButtonSegment(
                      value: ClassLevel.kesktase, label: Text('Kesktase')),
                  ButtonSegment(value: ClassLevel.koik, label: Text('Kõik')),
                ],
                selected: {_level},
                onSelectionChanged: (s) =>
                    setState(() => _level = s.first),
              ),
              const SizedBox(height: 16),

              // Day of week
              _SectionLabel(label: 'Nädalapäev'),
              const SizedBox(height: 8),
              _DayOfWeekSelector(
                selectedDay: _dayOfWeek,
                onDaySelected: (day) =>
                    setState(() => _dayOfWeek = day),
              ),
              const SizedBox(height: 16),

              // Start time
              TextFormField(
                controller: _startTimeController,
                decoration:
                    const InputDecoration(labelText: 'Algusaeg (HH:MM) *'),
                keyboardType: TextInputType.datetime,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Sisesta algusaeg';
                  final parts = v.split(':');
                  if (parts.length != 2) return 'Formaat: HH:MM';
                  final h = int.tryParse(parts[0]);
                  final m = int.tryParse(parts[1]);
                  if (h == null || m == null || h > 23 || m > 59) {
                    return 'Vigane kellaaeg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duration
              TextFormField(
                controller: _durationController,
                decoration:
                    const InputDecoration(labelText: 'Kestus (minutid) *'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Sisesta kestus minutites';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Max participants
              TextFormField(
                controller: _maxParticipantsController,
                decoration:
                    const InputDecoration(labelText: 'Maksimaalne osalejate arv *'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) {
                    return 'Sisesta maksimaalne osalejate arv';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Studio
              _SectionLabel(label: 'Stuudio'),
              const SizedBox(height: 8),
              studiosAsync.when(
                loading: () => const CircularProgressIndicator(
                    color: AppColors.primary),
                error: (e, _) =>
                    Text('Stuudiote laadimine ebaõnnestus: $e'),
                data: (studios) => DropdownButtonFormField<String?>(
                  value: _selectedStudioId,
                  decoration: const InputDecoration(
                      labelText: 'Stuudio (valikuline)'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Pole valitud')),
                    ...studios.map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name))),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedStudioId = v),
                ),
              ),
              const SizedBox(height: 16),

              // Instructor
              _SectionLabel(label: 'Treener'),
              const SizedBox(height: 8),
              instructorsAsync.when(
                loading: () => const CircularProgressIndicator(
                    color: AppColors.primary),
                error: (e, _) =>
                    Text('Treenerite laadimine ebaõnnestus: $e'),
                data: (instructors) => DropdownButtonFormField<String?>(
                  value: _selectedInstructorId,
                  decoration: const InputDecoration(
                      labelText: 'Treener (valikuline)'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Pole valitud')),
                    ...instructors.map((i) => DropdownMenuItem(
                        value: i.id, child: Text(i.fullName))),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedInstructorId = v),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEditing ? 'Salvesta muudatused' : 'Loo tunnidefinitsioon'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'level': _level.name,
        'day_of_week': _dayOfWeek,
        'start_time': '${_startTimeController.text.trim()}:00',
        'duration_minutes': int.parse(_durationController.text.trim()),
        'max_participants':
            int.parse(_maxParticipantsController.text.trim()),
        'studio_id': _selectedStudioId,
        'instructor_id': _selectedInstructorId,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isEditing) {
        await Supabase.instance.client
            .from('class_definitions')
            .update(data)
            .eq('id', widget.existing!.id);
      } else {
        await Supabase.instance.client
            .from('class_definitions')
            .insert(data);
      }

      ref.invalidate(classDefinitionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Tunnidefinitsioon uuendatud'
                : 'Tunnidefinitsioon loodud'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Salvestamine ebaõnnestus: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _DayOfWeekSelector extends StatelessWidget {
  final int selectedDay;
  final void Function(int) onDaySelected;

  const _DayOfWeekSelector({
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['E', 'T', 'K', 'N', 'R', 'L', 'P'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = selectedDay == day;
        return GestureDetector(
          onTap: () => onDaySelected(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.primaryLight,
              ),
            ),
            child: Center(
              child: Text(
                days[i],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
