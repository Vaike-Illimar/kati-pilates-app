import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kati_pilates/config/theme.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/models/class_instance.dart';
import 'package:kati_pilates/providers/auth_provider.dart';
import 'package:kati_pilates/providers/booking_provider.dart';
import 'package:kati_pilates/providers/card_provider.dart';
import 'package:kati_pilates/providers/schedule_provider.dart';
import 'package:kati_pilates/shared/utils/date_formatter.dart';
import 'package:kati_pilates/shared/widgets/avatar_circle.dart';

/// Provider to fetch a single class instance by ID.
final classDetailProvider =
    FutureProvider.autoDispose.family<ClassInstanceWithDetails, String>(
  (ref, classId) async {
    final classRepo = ref.watch(classRepositoryProvider);
    return classRepo.getClassInstance(classId);
  },
);

/// Provider to check if the current user has a booking for a specific class.
final classBookingProvider =
    FutureProvider.autoDispose.family<Booking?, String>(
  (ref, classInstanceId) async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;
    final bookingRepo = ref.watch(bookingRepositoryProvider);
    return bookingRepo.getBookingForClass(
      userId: user.id,
      classInstanceId: classInstanceId,
    );
  },
);

class ClassDetailScreen extends ConsumerStatefulWidget {
  const ClassDetailScreen({
    super.key,
    required this.classId,
  });

  final String classId;

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen> {
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final classAsync = ref.watch(classDetailProvider(widget.classId));
    final bookingAsync = ref.watch(classBookingProvider(widget.classId));
    final activeCardAsync = ref.watch(activeCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: classAsync.whenOrNull(
          data: (c) => Text(c.className ?? 'Tunni info'),
        ),
      ),
      body: classAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tunni info laadimine ebaõnnestus',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ref.invalidate(classDetailProvider(widget.classId));
                  },
                  child: const Text('Proovi uuesti'),
                ),
              ],
            ),
          ),
        ),
        data: (classInstance) {
          final existingBooking = bookingAsync.value;
          final isBooked = existingBooking != null &&
              (existingBooking.status == BookingStatus.confirmed ||
                  existingBooking.status == BookingStatus.waitlisted);
          final isWaitlisted =
              existingBooking?.status == BookingStatus.waitlisted;
          final isFull = classInstance.availableSpots <= 0;
          final activeCard = activeCardAsync.value;

          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- Hero section: time, date, instructor --
                      _buildHeroSection(context, classInstance),
                      const SizedBox(height: 20),

                      // -- Info card: level, duration, studio, spots --
                      _buildInfoCard(context, classInstance),
                      const SizedBox(height: 24),

                      // -- What to expect --
                      if (classInstance.classDescription != null &&
                          classInstance.classDescription!.isNotEmpty) ...[
                        Text(
                          'Mida oodata',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          classInstance.classDescription!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // -- Instructor section --
                      if (classInstance.instructorName != null)
                        _buildInstructorSection(context, classInstance),
                    ],
                  ),
                ),
              ),

              // -- Sticky bottom booking button --
              _buildBottomBookingBar(
                context,
                classInstance: classInstance,
                isBooked: isBooked,
                isWaitlisted: isWaitlisted,
                isFull: isFull,
                hasCard: activeCard != null,
                cardId: activeCard?.id,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(
      BuildContext context, ClassInstanceWithDetails classInstance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large time display
          Text(
            '${DateFormatter.formatTime(classInstance.startTime)} \u2013 ${DateFormatter.formatTime(classInstance.endTime)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          // Date
          Text(
            DateFormatter.formatDate(classInstance.date),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          const SizedBox(height: 12),
          // Instructor
          if (classInstance.instructorName != null)
            Row(
              children: [
                AvatarCircle(
                  name: classInstance.instructorName!,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Text(
                  classInstance.instructorName!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),

          // Cancelled badge
          if (classInstance.isCancelled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppShape.badgeRadius),
              ),
              child: const Text(
                'TUND ON TÜHISTATUD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, ClassInstanceWithDetails classInstance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Level + Duration
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: 'Tase',
                  value: classInstance.level != null
                      ? _formatLevel(classInstance.level!)
                      : 'Kõik tasemed',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.timer_outlined,
                  label: 'Kestvus',
                  value: classInstance.durationMinutes != null
                      ? '${classInstance.durationMinutes} min'
                      : '-',
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Row 2: Studio + Spots
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Stuudio',
                  value: classInstance.studioName ?? '-',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.people_outline_rounded,
                  label: 'Vabu kohti',
                  value: classInstance.availableSpots > 0
                      ? '${classInstance.availableSpots}/${classInstance.maxParticipants}'
                      : 'Täis',
                  valueColor: classInstance.availableSpots > 0
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorSection(
      BuildContext context, ClassInstanceWithDetails classInstance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Treener',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              AvatarCircle(
                name: classInstance.instructorName!,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classInstance.instructorName!,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pilates treener',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBookingBar(
    BuildContext context, {
    required ClassInstanceWithDetails classInstance,
    required bool isBooked,
    required bool isWaitlisted,
    required bool isFull,
    required bool hasCard,
    String? cardId,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show class time as subtitle
          if (isBooked)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isWaitlisted
                        ? Icons.hourglass_top_rounded
                        : Icons.check_circle_rounded,
                    size: 16,
                    color: isWaitlisted
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isWaitlisted
                        ? 'Oled ootenimekirjas'
                        : '${DateFormatter.formatTime(classInstance.startTime)} \u2013 ${DateFormatter.formatTime(classInstance.endTime)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            child: _buildBookingButton(
              context,
              classInstance: classInstance,
              isBooked: isBooked,
              isWaitlisted: isWaitlisted,
              isFull: isFull,
              hasCard: hasCard,
              cardId: cardId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(
    BuildContext context, {
    required ClassInstanceWithDetails classInstance,
    required bool isBooked,
    required bool isWaitlisted,
    required bool isFull,
    required bool hasCard,
    String? cardId,
  }) {
    // Class is cancelled
    if (classInstance.isCancelled) {
      return FilledButton(
        onPressed: null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
        child: const Text('Tund on tühistatud'),
      );
    }

    // Already booked
    if (isBooked) {
      return FilledButton(
        onPressed: null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.success.withValues(alpha: 0.8),
          disabledBackgroundColor: AppColors.success.withValues(alpha: 0.8),
          disabledForegroundColor: Colors.white,
        ),
        child: Text(isWaitlisted ? 'Ootenimekirjas' : 'Broneeritud'),
      );
    }

    // No active card
    if (!hasCard) {
      return FilledButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sul pole aktiivset kaarti. Osta kaart, et tunde broneerida.'),
            ),
          );
        },
        child: const Text('Broneeri tund'),
      );
    }

    // Full - join waitlist
    if (isFull) {
      return OutlinedButton(
        onPressed: _isBooking
            ? null
            : () => _handleBook(context, classInstance.id, cardId!),
        child: _isBooking
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Liitu järjekorraga'),
      );
    }

    // Available - book
    return FilledButton(
      onPressed: _isBooking
          ? null
          : () => _handleBook(context, classInstance.id, cardId!),
      child: _isBooking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Broneeri tund \u2014 1 sessioon kaardilt'),
    );
  }

  Future<void> _handleBook(
    BuildContext context,
    String classInstanceId,
    String cardId,
  ) async {
    setState(() => _isBooking = true);

    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);
      await bookingRepo.bookClass(
        classInstanceId: classInstanceId,
        cardId: cardId,
      );

      // Invalidate relevant providers to refresh data
      ref.invalidate(classBookingProvider(widget.classId));
      ref.invalidate(classDetailProvider(widget.classId));
      ref.invalidate(upcomingBookingsProvider);
      final selectedDate = ref.read(selectedDateProvider);
      ref.invalidate(scheduleProvider(selectedDate));
      ref.invalidate(activeCardProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tund on broneeritud!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Broneerimine ebaõnnestus: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  String _formatLevel(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'Algaja';
      case 'intermediate':
        return 'Keskmine';
      case 'advanced':
        return 'Edasijõudnu';
      case 'all':
        return 'Kõik tasemed';
      default:
        return level;
    }
  }
}

/// Small info item used in the class info card grid.
class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
