import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kati_pilates/config/theme.dart';

/// Shimmer placeholder for a class card in the schedule/booking lists.
class ClassCardShimmer extends StatelessWidget {
  const ClassCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Shimmer.fromColors(
        baseColor: AppColors.primaryLight.withValues(alpha: 0.2),
        highlightColor: AppColors.cardWhite,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Left time column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShimmerBox(width: 40, height: 14),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 40, height: 12),
                ],
              ),
              const SizedBox(width: 14),
              // Center info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ShimmerBox(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    _ShimmerBox(width: 120, height: 12),
                    const SizedBox(height: 4),
                    _ShimmerBox(width: 80, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right badge
              _ShimmerBox(width: 60, height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder list for schedule screen.
class ScheduleShimmer extends StatelessWidget {
  final int itemCount;

  const ScheduleShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (_, __) => const ClassCardShimmer(),
    );
  }
}

/// Shimmer placeholder for a notification item.
class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primaryLight.withValues(alpha: 0.2),
      highlightColor: AppColors.cardWhite,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
        ),
        child: Row(
          children: [
            const _ShimmerCircle(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 200, height: 12),
                  const SizedBox(height: 4),
                  _ShimmerBox(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for profile header.
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primaryLight.withValues(alpha: 0.2),
      highlightColor: AppColors.cardWhite,
      child: Column(
        children: [
          const _ShimmerCircle(size: 80),
          const SizedBox(height: 16),
          _ShimmerBox(width: 160, height: 20),
          const SizedBox(height: 8),
          _ShimmerBox(width: 220, height: 14),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for a booking history item.
class BookingHistoryShimmer extends StatelessWidget {
  const BookingHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primaryLight.withValues(alpha: 0.2),
      highlightColor: AppColors.cardWhite,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
        ),
        child: Row(
          children: [
            const _ShimmerCircle(size: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 140, height: 12),
                ],
              ),
            ),
            _ShimmerBox(width: 60, height: 24),
          ],
        ),
      ),
    );
  }
}

/// Generic shimmer list builder — shows [itemCount] shimmer items.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final Widget shimmerItem;

  const ShimmerList({
    super.key,
    required this.itemCount,
    required this.shimmerItem,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (_, __) => shimmerItem,
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;

  const _ShimmerCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        shape: BoxShape.circle,
      ),
    );
  }
}
