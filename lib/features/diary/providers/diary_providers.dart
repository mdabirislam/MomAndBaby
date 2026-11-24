import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/diary_entry.dart';
import '../data/diary_repository.dart';

final diaryRepositoryProvider = Provider((ref) => DiaryRepository());

final diaryEntriesProvider =
    StateNotifierProvider<DiaryNotifier, List<DiaryEntry>>((ref) {
      return DiaryNotifier(ref.watch(diaryRepositoryProvider));
    });

class DiaryNotifier extends StateNotifier<List<DiaryEntry>> {
  final DiaryRepository _repository;

  DiaryNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() => state = _repository.getAllEntries();

  Future<void> addEntry(
    String content, {
    String? mood,
    DateTime? date,
    List<String>? imagePaths,
    int? pregnancyWeek,
  }) async {
    final entry = DiaryEntry(
      date: date ?? DateTime.now(),
      content: content,
      mood: mood,
      imagePaths: imagePaths,
      pregnancyWeek: pregnancyWeek,
    );
    await _repository.addEntry(entry);
    refresh();
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await _repository.updateEntry(entry);
    refresh();
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    await _repository.deleteEntry(entry);
    refresh();
  }
}
