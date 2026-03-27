import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(Supabase.instance.client);
});

final upcomingBookingsProvider =
    FutureProvider.autoDispose<List<BookingDetailed>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final bookingRepo = ref.watch(bookingRepositoryProvider);
  return bookingRepo.getUpcomingBookings(user.id);
});

final pastBookingsProvider =
    FutureProvider.autoDispose<List<BookingDetailed>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final bookingRepo = ref.watch(bookingRepositoryProvider);
  return bookingRepo.getPastBookings(user.id);
});
