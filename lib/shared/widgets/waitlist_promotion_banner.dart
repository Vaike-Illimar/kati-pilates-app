import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Listens for waitlist_promoted notifications for the current user
/// and shows a banner when promotion occurs.
///
/// Place this widget near the top of the main shell scaffold.
class WaitlistPromotionListener extends ConsumerStatefulWidget {
  final Widget child;

  const WaitlistPromotionListener({super.key, required this.child});

  @override
  ConsumerState<WaitlistPromotionListener> createState() =>
      _WaitlistPromotionListenerState();
}

class _WaitlistPromotionListenerState
    extends ConsumerState<WaitlistPromotionListener> {
  RealtimeChannel? _channel;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Subscribe after first frame so providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSubscription();
    });
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _setupSubscription() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    _currentUserId = user.id;

    _channel = Supabase.instance.client
        .channel('waitlist_promotions:${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'user_notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['type'] == 'waitlist_promoted') {
              _showPromotionBanner(newRecord['title'] as String? ?? 'Koht vabanenud!');
            }
          },
        )
        .subscribe();
  }

  void _showPromotionBanner(String title) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: AppColors.success.withValues(alpha: 0.95),
        leading: const Icon(Icons.celebration_rounded,
            color: Colors.white, size: 28),
        content: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    // Auto-dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
