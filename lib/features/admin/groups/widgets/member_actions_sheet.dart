import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/providers/fixed_group_provider.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';

/// Shows the member actions bottom sheet.
/// Returns `true` if the member list should be refreshed (member was
/// paused or removed), or `null` / `false` otherwise.
Future<bool?> showMemberActionsSheet(
  BuildContext context,
  Map<String, dynamic> memberData,
  WidgetRef ref,
) {
  return showModalBottomSheet<bool>(
    context: context,
    shape: AppShape.sheetShape,
    backgroundColor: AppColors.cardWhite,
    showDragHandle: true,
    builder: (sheetContext) => _MemberActionsContent(
      memberData: memberData,
      ref: ref,
    ),
  );
}

class _MemberActionsContent extends StatelessWidget {
  const _MemberActionsContent({
    required this.memberData,
    required this.ref,
  });

  final Map<String, dynamic> memberData;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final profile = memberData['profiles'] as Map<String, dynamic>?;
    final fullName = profile?['full_name'] as String? ?? 'Kasutaja';
    final memberId = memberData['id'] as String;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Member avatar + name
            Row(
              children: [
                AvatarCircle(name: fullName, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            _ActionTile(
              icon: Icons.mail_outline_rounded,
              label: 'Saada s\u00f5num',
              onTap: () {
                Navigator.of(context).pop(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('S\u00f5numi saatmine tulekul'),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            _ActionTile(
              icon: Icons.pause_circle_outline_rounded,
              label: 'Peata koht ajutiselt',
              onTap: () => _confirmPause(context, memberId, fullName),
            ),
            const SizedBox(height: 4),
            _ActionTile(
              icon: Icons.person_remove_outlined,
              label: 'Eemalda r\u00fchmast',
              color: AppColors.error,
              onTap: () => _confirmRemove(context, memberId, fullName),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPause(
    BuildContext context,
    String memberId,
    String fullName,
  ) {
    Navigator.of(context).pop(); // Close the bottom sheet first
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Peata koht ajutiselt'),
        content: Text(
          'Kas oled kindel, et soovid peatada liikme $fullName koha ajutiselt?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('T\u00fchista'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final groupRepo = ref.read(fixedGroupRepositoryProvider);
                await groupRepo.pauseMembership(memberId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$fullName koht peatatud'),
                    ),
                  );
                  // Signal to caller to refresh
                  // Since we already popped the sheet, we need the caller
                  // to check. We use invalidation instead.
                  _invalidateGroupProviders();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viga: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Peata'),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(
    BuildContext context,
    String memberId,
    String fullName,
  ) {
    Navigator.of(context).pop(); // Close the bottom sheet first
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eemalda r\u00fchmast'),
        content: Text(
          'Kas oled kindel, et soovid eemaldada liikme $fullName r\u00fchmast? Seda tegevust ei saa tagasi v\u00f5tta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('T\u00fchista'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final groupRepo = ref.read(fixedGroupRepositoryProvider);
                await groupRepo.removeMember(memberId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$fullName eemaldatud r\u00fchmast'),
                    ),
                  );
                  _invalidateGroupProviders();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viga: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Eemalda'),
          ),
        ],
      ),
    );
  }

  void _invalidateGroupProviders() {
    final groupId = memberData['fixed_group_id'] as String?;
    if (groupId != null) {
      ref.invalidate(groupDetailProvider(groupId));
    }
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: tileColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: tileColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
