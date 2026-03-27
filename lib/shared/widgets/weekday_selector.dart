import 'package:flutter/material.dart';
import 'package:kati_pilates/config/constants.dart';
import 'package:kati_pilates/config/theme.dart';

class WeekdaySelector extends StatelessWidget {
  /// The currently selected date.
  final DateTime selectedDate;

  /// Called when a day is tapped.
  final ValueChanged<DateTime> onDateSelected;

  /// Whether to show the date number below the weekday letter.
  final bool showDates;

  /// Set of weekday indices (0=Monday … 6=Sunday) that are disabled.
  final Set<int> disabledDays;

  const WeekdaySelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.showDates = true,
    this.disabledDays = const {},
  });

  /// Returns the Monday of the week containing [date].
  DateTime _mondayOfWeek(DateTime date) {
    // DateTime.weekday: 1=Monday … 7=Sunday
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  @override
  Widget build(BuildContext context) {
    final monday = _mondayOfWeek(selectedDate);
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final day = monday.add(Duration(days: index));
        final isSelected = day == selectedDay;
        final isDisabled = disabledDays.contains(index);

        return _DayButton(
          letter: EstonianWeekday.short[index],
          dateNumber: showDates ? day.day : null,
          isSelected: isSelected,
          isDisabled: isDisabled,
          onTap: isDisabled ? null : () => onDateSelected(day),
        );
      }),
    );
  }
}

class _DayButton extends StatelessWidget {
  final String letter;
  final int? dateNumber;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _DayButton({
    required this.letter,
    this.dateNumber,
    required this.isSelected,
    required this.isDisabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.primaryDark : Colors.transparent;
    final textColor = isDisabled
        ? AppColors.textSecondary.withValues(alpha: 0.4)
        : isSelected
            ? Colors.white
            : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (dateNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              '$dateNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
