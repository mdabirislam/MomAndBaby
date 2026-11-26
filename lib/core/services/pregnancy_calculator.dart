class PregnancyCalculator {
  static const int totalPregnancyDays = 280;

  /// Calculates the expected delivery date (EDD) based on LMP
  static DateTime calculateEDD(DateTime lmp) {
    return lmp.add(const Duration(days: totalPregnancyDays));
  }

  /// Calculates the gestational age in days
  static int calculateGestationalDays(DateTime lmp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lmpDate = DateTime(lmp.year, lmp.month, lmp.day);
    return today.difference(lmpDate).inDays;
  }

  /// Returns current week (1-42)
  static int currentWeek(DateTime lmp) {
    final days = calculateGestationalDays(lmp);
    return (days / 7).floor() + 1;
  }

  /// Returns remaining days in the current week
  static int currentDayInWeek(DateTime lmp) {
    final days = calculateGestationalDays(lmp);
    return days % 7;
  }

  /// Returns total weeks and days as a map
  static Map<String, int> getWeeksAndDays(DateTime lmp) {
    final days = calculateGestationalDays(lmp);
    return {'weeks': (days / 7).floor(), 'days': days % 7};
  }

  /// Returns current trimester (1, 2, or 3)
  static int currentTrimester(DateTime lmp) {
    final week = currentWeek(lmp);
    if (week <= 13) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  /// Returns pregnancy month (1-10, as pregnancy is approx 10 lunar months)
  static int currentMonth(DateTime lmp) {
    final days = calculateGestationalDays(lmp);
    // Rough estimate: 28 days per lunar month
    return (days / 28).floor() + 1;
  }

  /// Returns progress percentage (0.0 to 1.0)
  static double progressPercentage(DateTime lmp) {
    final days = calculateGestationalDays(lmp);
    final progress = days / totalPregnancyDays;
    return progress.clamp(0.0, 1.0);
  }

  /// Returns remaining days until EDD
  static int remainingDays(DateTime lmp) {
    final edd = calculateEDD(lmp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return edd.difference(today).inDays;
  }
}
