import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/card_pause.dart';
import 'package:kati_pilates/models/profile.dart';
import 'package:kati_pilates/models/session_card.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/providers/card_provider.dart';
import 'package:kati_pilates/repositories/profile_repository.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _profileRepoProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

final _pauseClientProfileProvider =
    FutureProvider.autoDispose.family<Profile, String>((ref, userId) {
  final repo = ref.watch(_profileRepoProvider);
  return repo.getProfile(userId);
});

final _pauseClientCardProvider =
    FutureProvider.autoDispose.family<SessionCard?, String>((ref, cardId) async {
  // Fetch by card ID directly — get all cards and find the matching one
  final data = await Supabase.instance.client
      .from('session_cards')
      .select()
      .eq('id', cardId)
      .single();
  return SessionCard.fromJson(data);
});

class PauseCardScreen extends ConsumerStatefulWidget {
  final String userId;
  final String cardId;

  const PauseCardScreen({
    super.key,
    required this.userId,
    required this.cardId,
  });

  @override
  ConsumerState<PauseCardScreen> createState() => _PauseCardScreenState();
}

class _PauseCardScreenState extends ConsumerState<PauseCardScreen> {
  PauseReason _selectedReason = PauseReason.haigus;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _extensionDays => _endDate.difference(_startDate).inDays;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_pauseClientProfileProvider(widget.userId));
    final cardAsync = ref.watch(_pauseClientCardProvider(widget.cardId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Peata kaardi kehtivus'),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => _buildError(),
        data: (profile) => cardAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => _buildError(),
          data: (card) {
            if (card == null) return _buildError();
            return _buildForm(context, profile, card);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, Profile profile, SessionCard card) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client info line
          Text(
            '${profile.fullName} \u00b7 ${card.totalSessions}-tunnine kaart',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 28),

          // Reason selection
          Text(
            'Peatamise p\u00f5hjus',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PauseReason.values.map((reason) {
              final isSelected = _selectedReason == reason;
              return ChoiceChip(
                label: Text(_reasonLabel(reason)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedReason = reason);
                },
                selectedColor: AppColors.primaryLight,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShape.badgeRadius),
                  side: isSelected
                      ? const BorderSide(color: AppColors.primary, width: 1.5)
                      : BorderSide.none,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Date range
          Text(
            'Peatamise periood',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          // Start date
          _DatePickerField(
            label: 'Algus',
            date: _startDate,
            onTap: () => _pickDate(isStart: true),
          ),
          const SizedBox(height: 12),

          // End date
          _DatePickerField(
            label: 'L\u00f5pp',
            date: _endDate,
            onTap: () => _pickDate(isStart: false),
          ),
          const SizedBox(height: 16),

          // Extension info
          if (_extensionDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kehtivus pikeneb $_extensionDays p\u00e4eva v\u00f5rra',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 28),

          // Notes field
          Text(
            'M\u00e4rkus',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Valikuline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Lisa m\u00e4rkus...',
            ),
          ),
          const SizedBox(height: 32),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : () => _submit(context),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Kinnita peatamine'),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => context.pop(),
              child: const Text('T\u00fchista'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final first = isStart ? DateTime.now() : _startDate;
    final last = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        // Ensure end date is after start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 14));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit(BuildContext context) async {
    if (_extensionDays <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('L\u00f5ppkuup\u00e4ev peab olema p\u00e4rast alguskuup\u00e4eva')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cardRepo = ref.read(cardRepositoryProvider);
      final currentUser = ref.read(currentUserProvider);

      await cardRepo.pauseCard(
        cardId: widget.cardId,
        reason: _selectedReason.name,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        adminId: currentUser?.id ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaart peatatud')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Peatamine eba\u00f5nnestus')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Andmete laadimine eba\u00f5nnestus',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _reasonLabel(PauseReason reason) {
    switch (reason) {
      case PauseReason.haigus:
        return 'Haigus';
      case PauseReason.vigastus:
        return 'Vigastus';
      case PauseReason.puhkus:
        return 'Puhkus';
      case PauseReason.muu:
        return 'Muu';
    }
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppShape.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          border: Border.all(
            color: AppColors.primaryLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const Spacer(),
            Text(
              DateFormatter.formatDate(date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
