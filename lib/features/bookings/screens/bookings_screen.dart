import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/constants.dart';
import 'package:kati_pilates/config/routes.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/providers/booking_provider.dart';
import 'package:kati_pilates/shared/widgets/booking_list_item.dart';
import 'package:kati_pilates/shared/widgets/empty_state.dart';
import 'package:kati_pilates/features/bookings/widgets/cancel_sheet.dart';
import 'package:kati_pilates/features/bookings/widgets/late_cancel_warning.dart';
import 'package:kati_pilates/features/bookings/widgets/cancellation_success_banner.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  int _selectedTab = 0; // 0 = upcoming, 1 = past
  bool _showCancelBanner = false;
  bool _isCancelling = false;

  Future<void> _handleCancel(BookingDetailed booking) async {
    if (_isCancelling) return;

    // Determine if this is a late cancellation (< 2h before class start)
    final isLate = _isLateCancellation(booking);
    final CancelType cancelType;

    if (isLate) {
      final confirmed = await showLateCancelWarning(context, booking);
      if (confirmed != true) return;
      cancelType = CancelType.late;
    } else {
      final confirmed = await showCancelSheet(context, booking);
      if (confirmed != true) return;
      cancelType = CancelType.normal;
    }

    setState(() => _isCancelling = true);

    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);
      await bookingRepo.cancelBooking(
        bookingId: booking.id,
        cancelType: cancelType,
      );

      // Refresh both lists
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(pastBookingsProvider);

      if (mounted) {
        setState(() {
          _showCancelBanner = true;
          _isCancelling = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tuhistamine ebaonnestus. Proovi uuesti.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  bool _isLateCancellation(BookingDetailed booking) {
    if (booking.classDate == null || booking.classStartTime == null) {
      return false;
    }

    final timeParts = booking.classStartTime!.split(':');
    if (timeParts.length < 2) return false;

    final classStart = DateTime(
      booking.classDate!.year,
      booking.classDate!.month,
      booking.classDate!.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final now = DateTime.now();
    return classStart.difference(now) < AppConstants.lateCancelThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Minu broneeringud',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 20),

            // Tab pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TabPills(
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel success banner
            if (_showCancelBanner)
              CancellationSuccessBanner(
                onDismiss: () => setState(() => _showCancelBanner = false),
              ),

            // Content
            Expanded(
              child: _selectedTab == 0
                  ? _UpcomingTab(
                      onCancel: _handleCancel,
                      isCancelling: _isCancelling,
                    )
                  : const _PastTab(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab pills toggle
// ---------------------------------------------------------------------------
class _TabPills extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TabPills({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppShape.buttonRadius),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _PillButton(
            label: 'Tulevad',
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _PillButton(
            label: 'Moodunud',
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppShape.buttonRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upcoming bookings tab
// ---------------------------------------------------------------------------
class _UpcomingTab extends ConsumerWidget {
  final Future<void> Function(BookingDetailed booking) onCancel;
  final bool isCancelling;

  const _UpcomingTab({
    required this.onCancel,
    required this.isCancelling,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBookings = ref.watch(upcomingBookingsProvider);

    return asyncBookings.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Broneeringute laadimine ebaonnestus',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(upcomingBookingsProvider),
                child: const Text('Proovi uuesti'),
              ),
            ],
          ),
        ),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return EmptyState(
            icon: Icons.calendar_today_rounded,
            title: 'Tulevaid broneeringuid pole',
            actionLabel: 'Vaata tunniplaani',
            onAction: () => context.go(RoutePaths.schedule),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(upcomingBookingsProvider);
            // Wait for the provider to finish refreshing
            await ref.read(upcomingBookingsProvider.future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return BookingListItem(
                booking: booking,
                onCancel: isCancelling ? null : () => onCancel(booking),
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Past bookings tab
// ---------------------------------------------------------------------------
class _PastTab extends ConsumerWidget {
  const _PastTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBookings = ref.watch(pastBookingsProvider);

    return asyncBookings.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Broneeringute laadimine ebaonnestus',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(pastBookingsProvider),
                child: const Text('Proovi uuesti'),
              ),
            ],
          ),
        ),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'Varasemaid broneeringuid pole',
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(pastBookingsProvider);
            await ref.read(pastBookingsProvider.future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return BookingListItem(booking: bookings[index]);
            },
          ),
        );
      },
    );
  }
}
