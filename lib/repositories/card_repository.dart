import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/session_card.dart';
import 'package:kati_pilates/models/card_pause.dart';
import 'package:kati_pilates/models/booking.dart';

class CardRepository {
  final SupabaseClient _client;

  CardRepository(this._client);

  /// Get the active session card for a user.
  /// Returns the card with the earliest valid_until date that is still active.
  Future<SessionCard?> getActiveCard(String userId) async {
    final data = await _client
        .from('session_cards')
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('valid_until')
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return SessionCard.fromJson(data);
  }

  /// Get all session cards for a user.
  Future<List<SessionCard>> getAllCards(String userId) async {
    final data = await _client
        .from('session_cards')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data.map((json) => SessionCard.fromJson(json)).toList();
  }

  /// Get pause history for a specific card.
  Future<List<CardPause>> getCardPauses(String cardId) async {
    final data = await _client
        .from('card_pauses')
        .select()
        .eq('card_id', cardId)
        .order('start_date', ascending: false);
    return data.map((json) => CardPause.fromJson(json)).toList();
  }

  /// Get usage history (bookings) linked to a specific card.
  Future<List<BookingDetailed>> getUsageHistory(String cardId) async {
    final data = await _client
        .from('bookings_detailed')
        .select()
        .eq('card_id', cardId)
        .order('class_date', ascending: false);
    return data.map((json) => BookingDetailed.fromJson(json)).toList();
  }

  // ---------------------------------------------------------------------------
  // Admin methods
  // ---------------------------------------------------------------------------

  /// Admin: get the active card for a specific user.
  Future<SessionCard?> getClientCard(String userId) async {
    final data = await _client
        .from('session_cards')
        .select()
        .eq('user_id', userId)
        .inFilter('status', ['active', 'paused'])
        .order('valid_until')
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return SessionCard.fromJson(data);
  }

  /// Admin: add sessions to a card.
  Future<void> addSessions(String cardId, int sessions) async {
    // Use RPC or manual increment
    final card = await _client
        .from('session_cards')
        .select()
        .eq('id', cardId)
        .single();
    final current = card['remaining_sessions'] as int;
    final total = card['total_sessions'] as int;
    await _client.from('session_cards').update({
      'remaining_sessions': current + sessions,
      'total_sessions': total + sessions,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', cardId);
  }

  /// Admin: pause a card.
  Future<void> pauseCard({
    required String cardId,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
    required String adminId,
  }) async {
    final extensionDays = endDate.difference(startDate).inDays;

    // Insert pause record
    await _client.from('card_pauses').insert({
      'card_id': cardId,
      'reason': reason,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'notes': notes,
      'extension_days': extensionDays,
      'created_by': adminId,
    });

    // Update card status and extend validity
    final card = await _client
        .from('session_cards')
        .select()
        .eq('id', cardId)
        .single();
    final validUntil = DateTime.parse(card['valid_until'] as String);
    await _client.from('session_cards').update({
      'status': 'paused',
      'valid_until': validUntil.add(Duration(days: extensionDays)).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', cardId);
  }

  /// Admin: remove pause from a card.
  Future<void> unpauseCard(String cardId, String pauseId) async {
    // Delete the pause record
    await _client.from('card_pauses').delete().eq('id', pauseId);

    // Restore card status to active
    await _client.from('session_cards').update({
      'status': 'active',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', cardId);
  }

  /// Admin: get active pause for a card (if any).
  Future<CardPause?> getActivePause(String cardId) async {
    final data = await _client
        .from('card_pauses')
        .select()
        .eq('card_id', cardId)
        .gte('end_date', DateTime.now().toIso8601String())
        .order('start_date', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return CardPause.fromJson(data);
  }
}
