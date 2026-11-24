import 'package:hive/hive.dart';

part 'planner_task.g.dart';

@HiveType(typeId: 9)
class PlannerTask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String category;

  @HiveField(2)
  DateTime? dueDate;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime? reminderAt;

  @HiveField(6)
  String? templateId;

  PlannerTask({
    required this.title,
    required this.category,
    this.dueDate,
    this.notes,
    this.isCompleted = false,
    this.reminderAt,
    this.templateId,
  });
}
