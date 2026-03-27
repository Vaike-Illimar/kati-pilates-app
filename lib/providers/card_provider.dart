import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/session_card.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/repositories/card_repository.dart';

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository(Supabase.instance.client);
});

final activeCardProvider =
    FutureProvider.autoDispose<SessionCard?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final cardRepo = ref.watch(cardRepositoryProvider);
  return cardRepo.getActiveCard(user.id);
});
