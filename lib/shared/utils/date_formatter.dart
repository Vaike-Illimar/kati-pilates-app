import 'package:kati_pilates/config/constants.dart';

class DateFormatter {
  DateFormatter._();

  static const List<String> _monthNames = [
    'jaanuar',
    'veebruar',
    'märts',
    'aprill',
    'mai',
    'juuni',
    'juuli',
    'august',
    'september',
    'oktoober',
    'november',
    'detsember',
  ];

  static const List<String> _weekdayNamesLower = [
    'esmaspäev',
    'teisipäev',
    'kolmapäev',
    'neljapäev',
    'reede',
    'laupäev',
    'pühapäev',
  ];

  /// Format a time string, ensuring HH:mm format.
  /// Input may be "09:00:00" or "09:00" — returns "09:00".
  static String formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return time;
  }

  /// "12. märts 2026"
  static String formatDate(DateTime date) {
    return '${date.day}. ${_monthNames[date.month - 1]} ${date.year}';
  }

  /// "E 12. märts"  (short weekday + day + month)
  static String formatShortDate(DateTime date) {
    final weekdayShort = EstonianWeekday.shortFor(date.weekday);
    return '$weekdayShort ${date.day}. ${_monthNames[date.month - 1]}';
  }

  /// "Täna", "Homme", "Eile", or formatShortDate
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Täna';
    if (diff == 1) return 'Homme';
    if (diff == -1) return 'Eile';
    return formatShortDate(date);
  }

  /// Full Estonian month name (0-indexed from 1)
  static String monthName(int month) => _monthNames[month - 1];

  /// Full Estonian weekday name (1=Monday … 7=Sunday)
  static String weekdayName(int weekday) => _weekdayNamesLower[weekday - 1];

  /// Short weekday letter (1=Monday … 7=Sunday)
  static String weekdayShort(int weekday) =>
      EstonianWeekday.shortFor(weekday);

  /// Format date and time for booking list: "E 12. märts · 09:00"
  static String formatDateWithTime(DateTime date, String time) {
    return '${formatShortDate(date)} \u00b7 ${formatTime(time)}';
  }

  /// Format date and time range: "E 12. märts · 09:00–10:00"
  static String formatDateWithTimeRange(
    DateTime date,
    String startTime,
    String endTime,
  ) {
    return '${formatShortDate(date)} \u00b7 ${formatTime(startTime)}\u2013${formatTime(endTime)}';
  }
}
