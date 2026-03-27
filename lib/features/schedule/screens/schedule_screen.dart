import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kati_pilates/config/constants.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/models/class_instance.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/providers/booking_provider.dart';
import 'package:kati_pilates/providers/schedule_provider.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/utils/greeting_helper.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';
import 'package:kati_pilates/shared/widgets/class_card_widget.dart';
import 'package:kati_pilates/shared/widgets/empty_state.dart';
import 'package:kati_pilates/shared/widgets/weekday_selector.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final scheduleAsync = ref.watch(scheduleProvider(selectedDate));
    final upcomingBookingsAsync = ref.watch(upcomingBookingsProvider);
    final user = ref.watch(currentUserProvider);

    final userName = user?.userMetadata?['first_name'] as String? ??
        user?.email?.split('@').first ??
        '';

    // Count bookings this week for subtitle
    final weekBookingCount = upcomingBookingsAsync.whenOrNull(
          data: (bookings) {
            final now = DateTime.now();
            final startOfWeek =
                now.subtract(Duration(days: now.weekday - 1));
            final endOfWeek = startOfWeek.add(const Duration(days: 7));
            return bookings.where((b) {
              final classDate = b.classDate;
              if (classDate == null) return false;
              return classDate.isAfter(
                      startOfWeek.subtract(const Duration(days: 1))) &&
                  classDate.isBefore(endOfWeek);
            }).length;
          },
        ) ??
        0;

    // Build a set of class instance IDs the user has booked
    final bookedClassIds = upcomingBookingsAsync.whenOrNull(
          data: (bookings) => {
            for (final b in bookings)
              if (b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.waitlisted)
                b.classInstanceId: b,
          },
        ) ??
        <String, BookingDetailed>{};

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(scheduleProvider(selectedDate));
            ref.invalidate(upcomingBookingsProvider);
            // Wait for the schedule to refresh
            await ref.read(scheduleProvider(selectedDate).future);
          },
          child: CustomScrollView(
            slivers: [
              // -- Greeting header --
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName.isNotEmpty
                                  ? '${GreetingHelper.getGreeting()}, $userName'
                                  : GreetingHelper.getGreeting(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weekBookingCount > 0
                                  ? 'Sul on $weekBookingCount tundi sel nädalal'
                                  : 'Sul pole veel tunde sel nädalal',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      AvatarCircle(
                        name: userName,
                        size: 44,
                      ),
                    ],
                  ),
                ),
              ),

              // -- Weekday selector --
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: WeekdaySelector(
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      ref.read(selectedDateProvider.notifier).setDate(date);
                    },
                  ),
                ),
              ),

              // -- Date header --
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    _formatFullEstonianDate(selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),

              // -- Class list --
              scheduleAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tunniplaani laadimine ebaõnnestus',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            ref.invalidate(scheduleProvider(selectedDate));
                          },
                          child: const Text('Proovi uuesti'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (classes) {
                  if (classes.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.event_busy_rounded,
                        title: 'Täna tunde pole',
                        subtitle: 'Vali teine päev tunniplaanist',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    sliver: SliverList.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final classInstance = classes[index];
                        final booking = bookedClassIds[classInstance.id];

                        return GestureDetector(
                          onTap: () {
                            context.push('/schedule/${classInstance.id}');
                          },
                          child: ClassCardWidget(
                            classInstance: classInstance,
                            bookingStatus: booking?.status,
                            waitlistPosition: booking?.waitlistPosition,
                            onBook: classInstance.isCancelled
                                ? null
                                : () => _handleBooking(
                                      context,
                                      ref,
                                      classInstance,
                                      selectedDate,
                                    ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format a full Estonian date like "Esmaspäev, 15. märts"
  String _formatFullEstonianDate(DateTime date) {
    final weekdayName = EstonianWeekday.fullFor(date.weekday);
    final monthName = DateFormatter.monthName(date.month);
    return '$weekdayName, ${date.day}. $monthName';
  }

  Future<void> _handleBooking(
    BuildContext context,
    WidgetRef ref,
    ClassInstanceWithDetails classInstance,
    DateTime selectedDate,
  ) async {
    // Navigate to the class detail screen for full booking flow
    context.push('/schedule/${classInstance.id}');
  }
}
