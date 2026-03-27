import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/profile.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Profile> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return Profile.fromJson(data);
  }

  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId);
  }

  /// Admin: fetch all user profiles.
  Future<List<Profile>> getAllProfiles() async {
    final data = await _client
        .from('profiles')
        .select()
        .order('full_name');
    return data.map((json) => Profile.fromJson(json)).toList();
  }

  /// Admin: search profiles by name or email for adding group members, etc.
  Future<List<Profile>> searchProfiles(String query) async {
    final data = await _client
        .from('profiles')
        .select()
        .or('full_name.ilike.%$query%,email.ilike.%$query%')
        .order('full_name')
        .limit(20);
    return data.map((json) => Profile.fromJson(json)).toList();
  }
}
