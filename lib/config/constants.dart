class AppConstants {
  AppConstants._();

  // Booking rules
  static const Duration lateCancelThreshold = Duration(hours: 2);

  // Card expiry warning
  static const int cardExpiryWarningDays = 14;

  // Pagination
  static const int defaultPageSize = 20;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
}

class CardType {
  final String name;
  final int sessions;
  final double priceEur;
  final int validityDays;

  const CardType({
    required this.name,
    required this.sessions,
    required this.priceEur,
    required this.validityDays,
  });

  String get displayPrice => '€${priceEur.toStringAsFixed(0)}';
  String get displayValidity => '$validityDays päeva';
  String get displaySessions => '$sessions korda';

  static const List<CardType> all = [
    CardType(
      name: '4 korra kaart',
      sessions: 4,
      priceEur: 48,
      validityDays: 30,
    ),
    CardType(
      name: '10 korra kaart',
      sessions: 10,
      priceEur: 99,
      validityDays: 60,
    ),
  ];
}

class EstonianWeekday {
  EstonianWeekday._();

  /// Short labels: E T K N R L P (Monday–Sunday)
  static const List<String> short = ['E', 'T', 'K', 'N', 'R', 'L', 'P'];

  /// Full names (Monday–Sunday)
  static const List<String> full = [
    'Esmaspäev',
    'Teisipäev',
    'Kolmapäev',
    'Neljapäev',
    'Reede',
    'Laupäev',
    'Pühapäev',
  ];

  /// Returns short label for [DateTime.weekday] (1=Monday … 7=Sunday).
  static String shortFor(int weekday) => short[weekday - 1];

  /// Returns full name for [DateTime.weekday].
  static String fullFor(int weekday) => full[weekday - 1];
}
