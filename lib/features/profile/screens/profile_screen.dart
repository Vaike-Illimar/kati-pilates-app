import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/providers/notification_provider.dart';
import 'package:kati_pilates/providers/fixed_group_provider.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadPhoto() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final fileName = '${user.id}/avatar.$ext';

      // Upload to Supabase Storage bucket 'avatars'
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$ext',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update profile
      await Supabase.instance.client.from('profiles').update({
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      // Update user metadata (for immediate reflection)
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': publicUrl}),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profiilipilt uuendatud!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pildi üleslaadimine ebaõnnestus: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final unreadAsync = ref.watch(unreadCountProvider);
    final myGroupsAsync = ref.watch(myGroupsProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pole sisse logitud',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text('Logi sisse'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final fullName =
        user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['first_name'] as String? ??
        user.email?.split('@').first ??
        'Kasutaja';
    final email = user.email ?? '';
    final phone = user.userMetadata?['phone'] as String? ?? '';
    final avatarUrl = user.userMetadata?['avatar_url'] as String?;

    final unreadCount = unreadAsync.value ?? 0;
    final hasGroup = myGroupsAsync.when(
          data: (groups) => groups.isNotEmpty,
          loading: () => false,
          error: (_, __) => false,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Avatar with upload button
              Stack(
                children: [
                  AvatarCircle(
                    name: fullName,
                    imageUrl: avatarUrl,
                    size: 80,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadPhoto,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.background, width: 2),
                        ),
                        child: _isUploading
                            ? const Padding(
                                padding: EdgeInsets.all(4),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.camera_alt_rounded,
                                size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),

              // Email
              if (email.isNotEmpty)
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

              // Phone
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 8),

              // Menu items
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Teavitused',
                badge: unreadCount > 0 ? unreadCount : null,
                onTap: () => context.push('/profile/notifications'),
              ),
              _ProfileMenuItem(
                icon: Icons.group_outlined,
                title: 'Minu püsirühm',
                onTap: hasGroup
                    ? () => context.push('/profile/fixed-group')
                    : null,
                subtitle: hasGroup ? null : 'Püsirühm puudub',
              ),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Seaded',
                onTap: () {
                  // Placeholder — settings screen not yet implemented
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seaded on tulekul!'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              // Log out
              _ProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logi välja',
                isDestructive: true,
                onTap: () => _showLogoutDialog(context, ref),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
        ),
        title: const Text('Logi välja'),
        content: const Text('Kas oled kindel, et soovid välja logida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tühista'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final authRepo = ref.read(authRepositoryProvider);
              await authRepo.signOut();
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logi välja'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final int? badge;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null && !isDestructive;
    final textColor = isDestructive
        ? AppColors.error
        : isDisabled
            ? AppColors.textSecondary
            : AppColors.textPrimary;
    final iconColor = isDestructive
        ? AppColors.error
        : isDisabled
            ? AppColors.textSecondary
            : AppColors.primaryDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppShape.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppShape.badgeRadius),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            if (!isDestructive) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDisabled
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
