import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/profile.dart';
import 'package:kati_pilates/providers/fixed_group_provider.dart';
import 'package:kati_pilates/repositories/profile_repository.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

/// Provider for loading all profiles initially.
final _allProfilesProvider =
    FutureProvider.autoDispose<List<Profile>>((ref) async {
  final profileRepo = ref.watch(_profileRepositoryProvider);
  return profileRepo.getAllProfiles();
});

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({
    super.key,
    required this.groupId,
    this.groupName,
    this.weekdayShort,
    this.startTime,
  });

  final String groupId;
  final String? groupName;
  final String? weekdayShort;
  final String? startTime;

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _searchController = TextEditingController();
  final _selectedUserIds = <String>{};
  Timer? _debounce;
  List<Profile>? _searchResults;
  bool _isSearching = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final profileRepo = ref.read(_profileRepositoryProvider);
        final results = await profileRepo.searchProfiles(query.trim());
        if (mounted && _searchController.text.trim() == query.trim()) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  Future<void> _submitSelectedMembers() async {
    if (_selectedUserIds.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final groupRepo = ref.read(fixedGroupRepositoryProvider);
      for (final userId in _selectedUserIds) {
        await groupRepo.addMember(
          groupId: widget.groupId,
          userId: userId,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedUserIds.length} kasutaja${_selectedUserIds.length > 1 ? 't' : ''} lisatud',
            ),
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viga: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProfilesAsync = ref.watch(_allProfilesProvider);

    // Build subtitle
    String? subtitle;
    if (widget.groupName != null) {
      subtitle = widget.groupName!;
      if (widget.weekdayShort != null && widget.startTime != null) {
        subtitle += ' \u00b7 ${widget.weekdayShort} ${widget.startTime}';
      }
    }

    // Determine which list to show
    final profilesToShow = _searchResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lisa liige'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),

          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Otsi kasutajat nimega...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'REGISTREERITUD KASUTAJAD',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
            ),
          ),

          // User list
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : profilesToShow != null
                    ? _buildProfileList(profilesToShow)
                    : allProfilesAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                        error: (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Kasutajate laadimine ebaõnnestus',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton(
                                  onPressed: () =>
                                      ref.invalidate(_allProfilesProvider),
                                  child: const Text('Proovi uuesti'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        data: (profiles) => _buildProfileList(profiles),
                      ),
          ),

          // Bottom confirm button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedUserIds.isNotEmpty && !_isSubmitting
                      ? _submitSelectedMembers
                      : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Kinnita (${_selectedUserIds.length} kasutaja${_selectedUserIds.length != 1 ? 't' : ''})',
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList(List<Profile> profiles) {
    if (profiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Kasutajaid ei leitud',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        final isSelected = _selectedUserIds.contains(profile.id);

        return _ProfileTile(
          profile: profile,
          isSelected: isSelected,
          onToggle: () {
            setState(() {
              if (isSelected) {
                _selectedUserIds.remove(profile.id);
              } else {
                _selectedUserIds.add(profile.id);
              }
            });
          },
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.isSelected,
    required this.onToggle,
  });

  final Profile profile;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected
            ? AppColors.primaryLight.withValues(alpha: 0.15)
            : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppShape.cardRadius),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.primaryLight.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                AvatarCircle(
                  name: profile.fullName,
                  imageUrl: profile.avatarUrl,
                  size: 42,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.email,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primaryLight.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.add,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
