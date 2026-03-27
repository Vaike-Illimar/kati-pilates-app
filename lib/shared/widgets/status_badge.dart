import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Green badge — "Kinnitatud"
  factory StatusBadge.confirmed() {
    return const StatusBadge(
      label: 'Kinnitatud',
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }

  /// Purple text badge — "Vabad kohad: X"
  factory StatusBadge.available(int spots) {
    return StatusBadge(
      label: 'Vabad kohad: $spots',
      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.25),
      textColor: AppColors.primaryDark,
    );
  }

  /// Yellow badge — "Järjekord"
  factory StatusBadge.waitlist() {
    return const StatusBadge(
      label: 'Järjekord',
      backgroundColor: AppColors.warning,
      textColor: AppColors.textPrimary,
    );
  }

  /// Purple filled badge — "Püsirühm"
  factory StatusBadge.fixedGroup() {
    return const StatusBadge(
      label: 'Püsirühm',
      backgroundColor: AppColors.primaryDark,
      textColor: Colors.white,
    );
  }

  /// Red badge — "Tühistatud"
  factory StatusBadge.cancelled() {
    return const StatusBadge(
      label: 'Tühistatud',
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }

  /// Green badge — "Osaletud"
  factory StatusBadge.attended() {
    return const StatusBadge(
      label: 'Osaletud',
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppShape.badgeRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.2,
        ),
      ),
    );
  }
}
