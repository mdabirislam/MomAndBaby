import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 7)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String content;

  @HiveField(2)
  List<String>? imagePaths;

  @HiveField(3)
  String? mood;

  DiaryEntry({
    required this.date,
    required this.content,
    this.imagePaths,
    this.mood,
  });
}
