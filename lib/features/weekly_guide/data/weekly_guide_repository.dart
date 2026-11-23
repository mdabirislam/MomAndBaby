import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/pregnancy_week.dart';

class WeeklyGuideRepository {
  Future<List<PregnancyWeek>> loadAllWeeks() async {
    final String response = await rootBundle.loadString('assets/data/pregnancy_weeks.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => PregnancyWeek.fromJson(json)).toList();
  }

  Future<PregnancyWeek?> getWeek(int week) async {
    final weeks = await loadAllWeeks();
    return weeks.firstWhere((w) => w.week == week);
  }
}
