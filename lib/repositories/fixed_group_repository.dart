import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/fixed_group.dart';


class FixedGroupRepository {
  final SupabaseClient _client;

  FixedGroupRepository(this._client);

  /// Get groups where the user is an active member.
  Future<List<FixedGroup>> getMyGroups(String userId) async {
    final memberData = await _client
        .from('fixed_group_members')
        .select('fixed_group_id')
        .eq('user_id', userId)
        .eq('status', 'active');

    final groupIds = (memberData as List)
        .map((row) => row['fixed_group_id'] as String)
        .toList();

    if (groupIds.isEmpty) return [];

    final data = await _client
        .from('fixed_groups')
        .select()
        .inFilter('id', groupIds)
        .order('name');
    return data.map((json) => FixedGroup.fromJson(json)).toList();
  }

  /// Get all members of a specific group with their profile info.
  Future<List<Map<String, dynamic>>> getGroupMembers(
    String groupId,
  ) async {
    final data = await _client
        .from('fixed_group_members')
        .select('*, profiles(full_name, email)')
        .eq('fixed_group_id', groupId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get groups where the user has a pending invitation.
  Future<List<FixedGroup>> getPendingInvitations(String userId) async {
    final memberData = await _client
        .from('fixed_group_members')
        .select('fixed_group_id')
        .eq('user_id', userId)
        .eq('status', 'invited');

    final groupIds = (memberData as List)
        .map((row) => row['fixed_group_id'] as String)
        .toList();

    if (groupIds.isEmpty) return [];

    final data = await _client
        .from('fixed_groups')
        .select()
        .inFilter('id', groupIds)
        .order('name');
    return data.map((json) => FixedGroup.fromJson(json)).toList();
  }

  /// Respond to a group invitation (accept or decline).
  Future<void> respondToInvitation({
    required String memberId,
    required bool accept,
  }) async {
    await _client.from('fixed_group_members').update({
      'status': accept ? 'active' : 'declined',
      if (accept) 'joined_at': DateTime.now().toIso8601String(),
    }).eq('id', memberId);
  }

  // --- Admin methods ---

  /// Admin: get all fixed groups.
  Future<List<FixedGroup>> getAllGroups() async {
    final data = await _client
        .from('fixed_groups')
        .select()
        .order('name');
    return data.map((json) => FixedGroup.fromJson(json)).toList();
  }

  /// Fetch a single group by ID with its class definition details.
  Future<Map<String, dynamic>> getGroupWithDetails(String groupId) async {
    final data = await _client
        .from('fixed_groups')
        .select('*, class_definitions(name, description, day_of_week, start_time, duration_minutes, instructor_id, profiles:instructor_id(full_name, avatar_url))')
        .eq('id', groupId)
        .single();
    return Map<String, dynamic>.from(data);
  }

  /// Get the current user's membership record for a group.
  Future<Map<String, dynamic>?> getMembership({
    required String groupId,
    required String userId,
  }) async {
    final data = await _client
        .from('fixed_group_members')
        .select()
        .eq('fixed_group_id', groupId)
        .eq('user_id', userId)
        .maybeSingle();
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Pause a membership temporarily.
  Future<void> pauseMembership(String memberId) async {
    await _client.from('fixed_group_members').update({
      'status': 'paused',
      'paused_at': DateTime.now().toIso8601String(),
    }).eq('id', memberId);
  }

  /// Leave a group (remove membership).
  Future<void> leaveGroup(String memberId) async {
    await _client
        .from('fixed_group_members')
        .delete()
        .eq('id', memberId);
  }

  /// Admin: add a member to a group.
  Future<void> addMember({
    required String groupId,
    required String userId,
  }) async {
    await _client.from('fixed_group_members').insert({
      'fixed_group_id': groupId,
      'user_id': userId,
      'status': 'invited',
    });
  }

  /// Admin: remove a member from a group.
  Future<void> removeMember(String memberId) async {
    await _client
        .from('fixed_group_members')
        .delete()
        .eq('id', memberId);
  }
}
