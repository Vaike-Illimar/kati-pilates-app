import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/repositories/card_repository.dart';
import 'package:kati_pilates/providers/card_provider.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/empty_state.dart';

final _clientBookingHistoryProvider =
    FutureProvider.autoDispose.family<List<BookingDetailed>, String>(
  (ref, userId) async {
    // Get all cards for this user, then get usage history from each
    final cardRepo = ref.watch(cardRepositoryProvider);
    // Get full booking history via the bookings_detailed view
    final supabase = ref.watch(cardRepositoryProvider);
    // We use the booking repository approach directly
    final data = await supabase.getAllCards(userId);

    // Collect all bookings for all cards
    final allBookings = <BookingDetailed>[];
    for (final card in data) {
      final bookings = await cardRepo.getUsageHistory(card.id);
      allBookings.addAll(bookings);
    }

    // Sort by date descending
    allBookings.sort((a, b) {
      final dateA = a.classDate ?? DateTime(2000);
      final dateB = b.classDate ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return allBookings;
  },
);

class ClientBookingHistoryScreen extends ConsumerWidget {
  final String userId;

  const ClientBookingHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(_clientBookingHistoryProvider(userId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Broneeringute ajalugu'),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Laadimine ebaõnnestus',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    ref.invalidate(_clientBookingHistoryProvider(userId)),
                child: const Text('Proovi uuesti'),
              ),
            ],
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'Broneeringute ajalugu puudub',
              subtitle: 'Kliendil pole veel broneeringuid',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(_clientBookingHistoryProvider(userId));
              await ref.read(_clientBookingHistoryProvider(userId).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return _BookingHistoryCard(booking: bookings[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  final BookingDetailed booking;

  const _BookingHistoryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final statusColor = _statusColor(b.status);
    final statusLabel = _statusLabel(b.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.className ?? 'Nimetu tund',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                if (b.classDate != null)
                  Text(
                    b.classStartTime != null
                        ? DateFormatter.formatDateWithTime(
                            b.classDate!, b.classStartTime!)
                        : DateFormatter.formatDate(b.classDate!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                if (b.instructorName != null || b.studioName != null)
                  Text(
                    [b.instructorName, b.studioName]
                        .where((s) => s != null)
                        .join(' · '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              if (b.sessionDeducted) ...[
                const SizedBox(height: 4),
                Text(
                  '-1 sessioon',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppColors.primary;
      case BookingStatus.waitlisted:
        return AppColors.warning;
      case BookingStatus.cancelled:
        return AppColors.textSecondary;
      case BookingStatus.attended:
        return AppColors.success;
      case BookingStatus.noShow:
        return AppColors.error;
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Kinnitatud';
      case BookingStatus.waitlisted:
        return 'Ootenimekiri';
      case BookingStatus.cancelled:
        return 'Tühistatud';
      case BookingStatus.attended:
        return 'Kohal';
      case BookingStatus.noShow:
        return 'Ei ilmunud';
    }
  }
}
