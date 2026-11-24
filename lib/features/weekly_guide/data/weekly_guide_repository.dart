import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/pregnancy_week.dart';

class WeeklyGuideRepository {
  Future<List<PregnancyWeek>> loadAllWeeks() async {
    final response = await rootBundle.loadString(
      'assets/data/pregnancy_weeks.json',
    );
    final decoded = json.decode(response);

    if (decoded is! List) {
      throw const FormatException('Pregnancy week data must be a JSON list.');
    }

    final weeks =
        decoded
            .map((item) => PregnancyWeek.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.week.compareTo(b.week));

    final weekNumbers = weeks.map((item) => item.week).toSet();
    if (weeks.length != 40 ||
        weekNumbers.length != 40 ||
        !List.generate(40, (index) => index + 1).every(weekNumbers.contains)) {
      throw const FormatException(
        'Pregnancy week data must contain each week from 1 to 40 exactly once.',
      );
    }

    return weeks;
  }

  Future<PregnancyWeek?> getWeek(int week) async {
    if (week < 1 || week > 40) return null;

    final weeks = await loadAllWeeks();
    for (final item in weeks) {
      if (item.week == week) return item;
    }
    return null;
  }
}
