import 'package:hive/hive.dart';

part 'daily_care.g.dart';

@HiveType(typeId: 1)
class WaterLog extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int amountMl;

  WaterLog({required this.date, required this.amountMl});
}

@HiveType(typeId: 2)
class KickCount extends HiveObject {
  @HiveField(0)
  DateTime startTime;

  @HiveField(1)
  int count;

  @HiveField(2)
  Duration duration;

  KickCount({
    required this.startTime,
    required this.count,
    required this.duration,
  });
}

@HiveType(typeId: 3)
class SymptomLog extends HiveObject {
  @HiveField(0)
  DateTime dateTime;

  @HiveField(1)
  String symptomName;

  @HiveField(2)
  int severity; // 1-5

  @HiveField(3)
  String? notes;

  SymptomLog({
    required this.dateTime,
    required this.symptomName,
    required this.severity,
    this.notes,
  });
}
