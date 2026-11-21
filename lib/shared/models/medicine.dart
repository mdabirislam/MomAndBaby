import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 4)
class Medicine extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String dosage;

  @HiveField(2)
  List<DateTime> reminderTimes;

  @HiveField(3)
  bool isActive;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime? endDate;

  Medicine({
    required this.name,
    required this.dosage,
    required this.reminderTimes,
    this.isActive = true,
    required this.startDate,
    this.endDate,
  });
}

@HiveType(typeId: 5)
class MedicineLog extends HiveObject {
  @HiveField(0)
  String medicineId; // Use Hive key

  @HiveField(1)
  DateTime takenAt;

  MedicineLog({required this.medicineId, required this.takenAt});
}
