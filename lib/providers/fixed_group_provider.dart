import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/fixed_group.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/repositories/fixed_group_repository.dart';

final fixedGroupRepositoryProvider = Provider<FixedGroupRepository>((ref) {
  return FixedGroupRepository(Supabase.instance.client);
});

final myGroupsProvider =
    FutureProvider.autoDispose<List<FixedGroup>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final groupRepo = ref.watch(fixedGroupRepositoryProvider);
  return groupRepo.getMyGroups(user.id);
});

final pendingInvitationsProvider =
    FutureProvider.autoDispose<List<FixedGroup>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final groupRepo = ref.watch(fixedGroupRepositoryProvider);
  return groupRepo.getPendingInvitations(user.id);
});

/// Fetch a single group with class definition details (name, schedule, instructor).
final groupDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, groupId) async {
    final groupRepo = ref.watch(fixedGroupRepositoryProvider);
    return groupRepo.getGroupWithDetails(groupId);
  },
);

/// Fetch the current user's membership record for a group.
final groupMembershipProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, String>(
  (ref, groupId) async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;
    final groupRepo = ref.watch(fixedGroupRepositoryProvider);
    return groupRepo.getMembership(groupId: groupId, userId: user.id);
  },
);
