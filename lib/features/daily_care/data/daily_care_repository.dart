import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/hive_service.dart';
import '../../../shared/models/daily_care.dart';

class DailyCareRepository {
  final Box<WaterLog> _waterBox = HiveService.getBox<WaterLog>(HiveService.waterBoxName);
  final Box<KickCount> _kickBox = HiveService.getBox<KickCount>(HiveService.kickBoxName);
  final Box<SymptomLog> _symptomBox = HiveService.getBox<SymptomLog>(HiveService.symptomBoxName);

  // Water methods
  Future<void> addWater(WaterLog log) async {
    await _waterBox.add(log);
  }

  List<WaterLog> getWaterLogsForDate(DateTime date) {
    return _waterBox.values.where((log) {
      return log.date.year == date.year &&
             log.date.month == date.month &&
             log.date.day == date.day;
    }).toList();
  }

  int getTotalWaterForDate(DateTime date) {
    final logs = getWaterLogsForDate(date);
    return logs.fold(0, (sum, log) => sum + log.amountMl);
  }

  // Kick count methods
  Future<void> addKickCount(KickCount log) async {
    await _kickBox.add(log);
  }

  List<KickCount> getKickCountsForDate(DateTime date) {
    return _kickBox.values.where((log) {
      return log.startTime.year == date.year &&
             log.startTime.month == date.month &&
             log.startTime.day == date.day;
    }).toList();
  }
}
