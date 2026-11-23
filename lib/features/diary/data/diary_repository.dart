import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/hive_service.dart';
import '../../../shared/models/diary_entry.dart';

class DiaryRepository {
  final Box<DiaryEntry> _diaryBox = HiveService.getBox<DiaryEntry>(HiveService.diaryBoxName);

  Future<void> addEntry(DiaryEntry entry) async {
    await _diaryBox.add(entry);
  }

  Future<void> updateEntry(int index, DiaryEntry entry) async {
    await _diaryBox.putAt(index, entry);
  }

  Future<void> deleteEntry(int index) async {
    await _diaryBox.deleteAt(index);
  }

  List<DiaryEntry> getAllEntries() {
    final entries = _diaryBox.values.toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }
}
