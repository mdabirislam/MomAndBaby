import 'package:hive/hive.dart';

part 'medical_record.g.dart';

@HiveType(typeId: 8)
class MedicalRecord extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String category; // Ultrasound, Blood Test, Prescription, etc.

  @HiveField(3)
  List<String> filePaths;

  @HiveField(4)
  String? notes;

  MedicalRecord({
    required this.title,
    required this.date,
    required this.category,
    required this.filePaths,
    this.notes,
  });
}
