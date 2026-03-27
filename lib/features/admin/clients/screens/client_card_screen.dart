import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/constants.dart' as constants;
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/card_pause.dart';
import 'package:kati_pilates/models/profile.dart';
import 'package:kati_pilates/models/session_card.dart';
import 'package:kati_pilates/providers/card_provider.dart';
import 'package:kati_pilates/repositories/profile_repository.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';
import 'package:kati_pilates/features/card/widgets/session_card_visual.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _profileRepoProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

final _clientProfileProvider =
    FutureProvider.autoDispose.family<Profile, String>((ref, userId) {
  final repo = ref.watch(_profileRepoProvider);
  return repo.getProfile(userId);
});

final _clientCardProvider =
    FutureProvider.autoDispose.family<SessionCard?, String>((ref, userId) {
  final cardRepo = ref.watch(cardRepositoryProvider);
  return cardRepo.getClientCard(userId);
});

final _activePauseProvider =
    FutureProvider.autoDispose.family<CardPause?, String>((ref, cardId) {
  final cardRepo = ref.watch(cardRepositoryProvider);
  return cardRepo.getActivePause(cardId);
});

class ClientCardScreen extends ConsumerWidget {
  final String userId;

  const ClientCardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(_clientProfileProvider(userId));
    final cardAsync = ref.watch(_clientCardProvider(userId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Kliendi kaart'),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _buildError(context, ref),
        data: (profile) => cardAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => _buildError(context, ref),
          data: (card) => _buildContent(context, ref, profile, card),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
    SessionCard? card,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(_clientProfileProvider(userId));
        ref.invalidate(_clientCardProvider(userId));
        await ref.read(_clientCardProvider(userId).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Client info header
            _buildClientHeader(context, profile),
            const SizedBox(height: 24),

            if (card == null)
              _buildNoCard(context)
            else ...[
              // Session card visual
              SessionCardVisual(card: card),
              const SizedBox(height: 12),

              // Expiry warning
              if (card.status == CardStatus.active)
                _buildExpiryWarning(context, card),

              // Paused banner + pause info
              if (card.status == CardStatus.paused)
                _PausedSection(cardId: card.id),

              const SizedBox(height: 24),

              // Card management section
              _buildManagementSection(context, ref, card),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientHeader(BuildContext context, Profile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          AvatarCircle(
            name: profile.fullName,
            imageUrl: profile.avatarUrl,
            size: 52,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryWarning(BuildContext context, SessionCard card) {
    final daysLeft = card.validUntil.difference(DateTime.now()).inDays;
    if (daysLeft < 0 || daysLeft > constants.AppConstants.cardExpiryWarningDays) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '\u26a0 Kaart aegub $daysLeft p\u00e4eva p\u00e4rast',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(
    BuildContext context,
    WidgetRef ref,
    SessionCard card,
  ) {
    final isPaused = card.status == CardStatus.paused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Kaardi haldus',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 8),

        // Add sessions
        _ManagementRow(
          icon: Icons.add_circle_outline_rounded,
          title: 'Lisa tunnid',
          subtitle: 'Lisa kaardile uusi tunde',
          onTap: () => _showAddSessionsDialog(context, ref, card),
        ),

        const Divider(indent: 20, endIndent: 20),

        // Pause or unpause
        if (!isPaused)
          _ManagementRow(
            icon: Icons.pause_circle_outline_rounded,
            title: 'Peata kehtivus',
            subtitle: 'Peatab kaardi kehtivuse',
            onTap: () => context.push(
              '/admin/clients/$userId/pause/${card.id}',
            ),
          )
        else
          _ManagementRow(
            icon: Icons.play_circle_outline_rounded,
            title: 'Eemalda peatamine',
            subtitle: 'Taastab kaardi kehtivuse',
            onTap: () => _confirmUnpause(context, ref, card),
          ),
      ],
    );
  }

  void _showAddSessionsDialog(
    BuildContext context,
    WidgetRef ref,
    SessionCard card,
  ) {
    int sessions = 1;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
          ),
          title: const Text('Lisa tunnid'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mitu tundi soovid lisada?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: sessions > 1
                        ? () => setDialogState(() => sessions--)
                        : null,
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                      foregroundColor: AppColors.primaryDark,
                      disabledBackgroundColor:
                          AppColors.primaryLight.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '$sessions',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 24),
                  IconButton.filled(
                    onPressed: () => setDialogState(() => sessions++),
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                      foregroundColor: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('T\u00fchista'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _addSessions(context, ref, card.id, sessions);
              },
              child: const Text('Lisa'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSessions(
    BuildContext context,
    WidgetRef ref,
    String cardId,
    int sessions,
  ) async {
    try {
      final cardRepo = ref.read(cardRepositoryProvider);
      await cardRepo.addSessions(cardId, sessions);
      ref.invalidate(_clientCardProvider(userId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$sessions tundi lisatud')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tundide lisamine eba\u00f5nnestus')),
        );
      }
    }
  }

  void _confirmUnpause(
    BuildContext context,
    WidgetRef ref,
    SessionCard card,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
        ),
        title: const Text('Eemalda peatamine'),
        content: const Text('Kas oled kindel, et soovid peatamise eemaldada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('T\u00fchista'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _unpauseCard(context, ref, card);
            },
            child: const Text('Eemalda'),
          ),
        ],
      ),
    );
  }

  Future<void> _unpauseCard(
    BuildContext context,
    WidgetRef ref,
    SessionCard card,
  ) async {
    try {
      final cardRepo = ref.read(cardRepositoryProvider);
      final pause = await cardRepo.getActivePause(card.id);
      if (pause == null) return;
      await cardRepo.unpauseCard(card.id, pause.id);
      ref.invalidate(_clientCardProvider(userId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Peatamine eemaldatud')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Peatamise eemaldamine eba\u00f5nnestus')),
        );
      }
    }
  }

  Widget _buildNoCard(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: Column(
          children: [
            Icon(
              Icons.credit_card_off_rounded,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Kliendil pole aktiivset kaarti',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                ref.invalidate(_clientProfileProvider(userId));
                ref.invalidate(_clientCardProvider(userId));
              },
              child: const Text('Proovi uuesti'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section shown when a card is paused — loads pause details and displays them.
class _PausedSection extends ConsumerWidget {
  final String cardId;

  const _PausedSection({required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pauseAsync = ref.watch(_activePauseProvider(cardId));

    return Column(
      children: [
        // Paused status banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.pause_circle_outline_rounded,
                color: AppColors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kaart peatatud',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Pause details
        pauseAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (pause) {
            if (pause == null) return const SizedBox.shrink();
            return _buildPauseDetails(context, pause);
          },
        ),
      ],
    );
  }

  Widget _buildPauseDetails(BuildContext context, CardPause pause) {
    final reasonLabel = _reasonLabel(pause.reason);
    final period =
        '${DateFormatter.formatDate(pause.startDate)} \u2013 ${DateFormatter.formatDate(pause.endDate)}';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow(context, 'P\u00f5hjus', reasonLabel),
          const SizedBox(height: 8),
          _detailRow(context, 'Periood', period),
          if (pause.notes != null && pause.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _detailRow(context, 'M\u00e4rkus', pause.notes!),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
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

class _ManagementRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
