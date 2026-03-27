import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/providers/schedule_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget that subscribes to bookings table changes for a given class instance
/// and refreshes availability in real-time.
///
/// Wraps a child builder that receives the latest availability data.
class RealtimeAvailabilityListener extends ConsumerStatefulWidget {
  final String classInstanceId;
  final Widget child;

  const RealtimeAvailabilityListener({
    super.key,
    required this.classInstanceId,
    required this.child,
  });

  @override
  ConsumerState<RealtimeAvailabilityListener> createState() =>
      _RealtimeAvailabilityListenerState();
}

class _RealtimeAvailabilityListenerState
    extends ConsumerState<RealtimeAvailabilityListener> {
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _subscribeToBookings();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _subscribeToBookings() {
    _channel = Supabase.instance.client
        .channel('bookings:${widget.classInstanceId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'class_instance_id',
            value: widget.classInstanceId,
          ),
          callback: (_) {
            // Invalidate the class detail provider to refresh availability
            if (mounted) {
              ref.invalidate(classRepositoryProvider);
            }
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Small availability indicator widget that shows confirmed/total spots
/// and subscribes to real-time updates.
class RealtimeAvailabilityBadge extends ConsumerStatefulWidget {
  final String classInstanceId;
  final int initialConfirmedCount;
  final int maxParticipants;
  final int initialAvailableSpots;

  const RealtimeAvailabilityBadge({
    super.key,
    required this.classInstanceId,
    required this.initialConfirmedCount,
    required this.maxParticipants,
    required this.initialAvailableSpots,
  });

  @override
  ConsumerState<RealtimeAvailabilityBadge> createState() =>
      _RealtimeAvailabilityBadgeState();
}

class _RealtimeAvailabilityBadgeState
    extends ConsumerState<RealtimeAvailabilityBadge> {
  late int _confirmedCount;
  late int _availableSpots;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _confirmedCount = widget.initialConfirmedCount;
    _availableSpots = widget.initialAvailableSpots;
    _subscribeToBookings();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _subscribeToBookings() {
    _channel = Supabase.instance.client
        .channel('availability:${widget.classInstanceId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'class_instance_id',
            value: widget.classInstanceId,
          ),
          callback: (_) => _refreshCount(),
        )
        .subscribe();
  }

  Future<void> _refreshCount() async {
    try {
      final result = await Supabase.instance.client
          .from('class_instances_with_counts')
          .select('confirmed_count, available_spots')
          .eq('id', widget.classInstanceId)
          .single();

      if (mounted) {
        setState(() {
          _confirmedCount = result['confirmed_count'] as int? ?? _confirmedCount;
          _availableSpots = result['available_spots'] as int? ?? _availableSpots;
        });
      }
    } catch (_) {
      // Keep existing values on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFull = _availableSpots <= 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.people_outline_rounded,
          size: 16,
          color: isFull ? AppColors.error : AppColors.success,
        ),
        const SizedBox(width: 4),
        Text(
          isFull
              ? 'Täis'
              : '$_availableSpots/${widget.maxParticipants} vaba',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isFull ? AppColors.error : AppColors.success,
          ),
        ),
      ],
    );
  }
}
