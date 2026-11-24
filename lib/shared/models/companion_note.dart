import 'package:hive/hive.dart';

part 'companion_note.g.dart';

@HiveType(typeId: 10)
class CompanionNote extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  String author;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isPinned;

  CompanionNote({
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.createdAt,
    this.isPinned = false,
  });
}
