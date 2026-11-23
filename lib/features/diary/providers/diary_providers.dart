import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/diary_repository.dart';
import '../../../shared/models/diary_entry.dart';

final diaryRepositoryProvider = Provider((ref) => DiaryRepository());

final diaryEntriesProvider = StateNotifierProvider<DiaryNotifier, List<DiaryEntry>>((ref) {
  return DiaryNotifier(ref.watch(diaryRepositoryProvider));
});

class DiaryNotifier extends StateNotifier<List<DiaryEntry>> {
  final DiaryRepository _repository;

  DiaryNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.getAllEntries();
  }

  Future<void> addEntry(String content, {String? mood}) async {
    final entry = DiaryEntry(date: DateTime.now(), content: content, mood: mood);
    await _repository.addEntry(entry);
    refresh();
  }

  Future<void> deleteEntry(int index) async {
    await _repository.deleteEntry(index);
    refresh();
  }
}
