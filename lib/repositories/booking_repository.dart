import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/booking.dart';

class BookingRepository {
  final SupabaseClient _client;

  BookingRepository(this._client);

  /// Book a class by calling the book-class edge function.
  /// Returns the created Booking.
  Future<Booking> bookClass({
    required String classInstanceId,
    required String cardId,
  }) async {
    final response = await _client.functions.invoke(
      'book-class',
      body: {
        'class_instance_id': classInstanceId,
        'card_id': cardId,
      },
    );
    final data = jsonDecode(response.data as String) as Map<String, dynamic>;
    return Booking.fromJson(data);
  }

  /// Cancel a booking by calling the cancel-booking edge function.
  Future<void> cancelBooking({
    required String bookingId,
    required CancelType cancelType,
  }) async {
    await _client.functions.invoke(
      'cancel-booking',
      body: {
        'booking_id': bookingId,
        'cancel_type': cancelType.name,
      },
    );
  }

  /// Join the waitlist for a class by calling the book-class edge function
  /// (the server determines confirmed vs waitlisted based on capacity).
  Future<Booking> joinWaitlist({
    required String classInstanceId,
    required String cardId,
  }) async {
    final response = await _client.functions.invoke(
      'book-class',
      body: {
        'class_instance_id': classInstanceId,
        'card_id': cardId,
      },
    );
    final data = jsonDecode(response.data as String) as Map<String, dynamic>;
    return Booking.fromJson(data);
  }

  /// Get upcoming bookings for a user from the bookings_detailed view.
  /// Includes confirmed and waitlisted bookings with future class dates.
  Future<List<BookingDetailed>> getUpcomingBookings(String userId) async {
    final now = DateTime.now().toIso8601String().split('T').first;
    final data = await _client
        .from('bookings_detailed')
        .select()
        .eq('user_id', userId)
        .gte('class_date', now)
        .inFilter('status', ['confirmed', 'waitlisted'])
        .order('class_date')
        .order('class_start_time');
    return data.map((json) => BookingDetailed.fromJson(json)).toList();
  }

  /// Get past bookings for a user from the bookings_detailed view.
  /// Includes past dates or cancelled/attended bookings.
  Future<List<BookingDetailed>> getPastBookings(String userId) async {
    final now = DateTime.now().toIso8601String().split('T').first;
    final data = await _client
        .from('bookings_detailed')
        .select()
        .eq('user_id', userId)
        .or('class_date.lt.$now,status.in.(cancelled,attended,no_show)')
        .order('class_date', ascending: false)
        .order('class_start_time', ascending: false);
    return data.map((json) => BookingDetailed.fromJson(json)).toList();
  }

  /// Check if a user already has a booking for a specific class instance.
  Future<Booking?> getBookingForClass({
    required String userId,
    required String classInstanceId,
  }) async {
    final data = await _client
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .eq('class_instance_id', classInstanceId)
        .inFilter('status', ['confirmed', 'waitlisted'])
        .maybeSingle();
    if (data == null) return null;
    return Booking.fromJson(data);
  }
}
