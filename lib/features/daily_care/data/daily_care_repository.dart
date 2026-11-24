import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/database/hive_service.dart';
import '../../../shared/models/daily_care.dart';

class DailyCareRepository {
  final Box<WaterLog> _waterBox = HiveService.getBox<WaterLog>(
    HiveService.waterBoxName,
  );
  final Box<KickCount> _kickBox = HiveService.getBox<KickCount>(
    HiveService.kickBoxName,
  );
  final Box<SymptomLog> _symptomBox = HiveService.getBox<SymptomLog>(
    HiveService.symptomBoxName,
  );

  // Water tracking
  Future<void> addWater(WaterLog log) async => _waterBox.add(log);

  List<WaterLog> getWaterLogsForDate(DateTime date) {
    final logs = _waterBox.values
        .where((log) => _sameDate(log.date, date))
        .toList();
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  int getTotalWaterForDate(DateTime date) =>
      getWaterLogsForDate(date).fold(0, (total, log) => total + log.amountMl);

  Future<void> deleteWaterLog(WaterLog log) => log.delete();

  // Fetal movement session records. These are personal records, not a
  // diagnostic count or a universal movement target.
  Future<void> addKickCount(KickCount log) async => _kickBox.add(log);

  List<KickCount> getKickCountsForDate(DateTime date) {
    final logs = _kickBox.values
        .where((log) => _sameDate(log.startTime, date))
        .toList();
    logs.sort((a, b) => b.startTime.compareTo(a.startTime));
    return logs;
  }

  // Symptom diary
  Future<void> addSymptom(SymptomLog log) async => _symptomBox.add(log);

  List<SymptomLog> getSymptomsForDate(DateTime date) {
    final logs = _symptomBox.values
        .where((log) => _sameDate(log.dateTime, date))
        .toList();
    logs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return logs;
  }

  List<SymptomLog> getAllSymptoms() {
    final logs = _symptomBox.values.toList();
    logs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return logs;
  }

  Future<void> deleteSymptom(SymptomLog log) => log.delete();

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
