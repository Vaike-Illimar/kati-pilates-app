class GreetingHelper {
  GreetingHelper._();

  /// Returns an Estonian greeting based on the current time of day.
  /// - Before 12:00 → "Tere hommikust"
  /// - 12:00–16:59  → "Tere päevast"
  /// - 17:00+       → "Tere õhtust"
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Tere hommikust';
    if (hour < 17) return 'Tere päevast';
    return 'Tere õhtust';
  }
}
