import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 6)
class Appointment extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime dateTime;

  @HiveField(2)
  String? doctorName;

  @HiveField(3)
  String? location;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  bool isCompleted;

  Appointment({
    required this.title,
    required this.dateTime,
    this.doctorName,
    this.location,
    this.notes,
    this.isCompleted = false,
  });
}
