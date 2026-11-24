import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/daily_care.dart';
import '../data/daily_care_repository.dart';

final dailyCareRepositoryProvider = Provider<DailyCareRepository>(
  (ref) => DailyCareRepository(),
);

final todayWaterProvider = StateNotifierProvider<TodayWaterNotifier, int>((
  ref,
) {
  return TodayWaterNotifier(ref.watch(dailyCareRepositoryProvider));
});

class TodayWaterNotifier extends StateNotifier<int> {
  TodayWaterNotifier(this._repository) : super(0) {
    refresh();
  }

  final DailyCareRepository _repository;

  void refresh() {
    state = _repository.getTotalWaterForDate(DateTime.now());
  }

  Future<void> addWater(int ml) async {
    if (ml <= 0) return;
    await _repository.addWater(WaterLog(date: DateTime.now(), amountMl: ml));
    refresh();
  }
}

final kickCounterProvider =
    StateNotifierProvider<KickCounterNotifier, List<KickCount>>((ref) {
      return KickCounterNotifier(ref.watch(dailyCareRepositoryProvider));
    });

class KickCounterNotifier extends StateNotifier<List<KickCount>> {
  KickCounterNotifier(this._repository) : super(const []) {
    refresh();
  }

  final DailyCareRepository _repository;

  void refresh() {
    state = _repository.getKickCountsForDate(DateTime.now());
  }

  Future<void> saveSession(int count, Duration duration) async {
    if (count <= 0 || duration.isNegative) return;
    await _repository.addKickCount(
      KickCount(
        startTime: DateTime.now().subtract(duration),
        count: count,
        duration: duration,
      ),
    );
    refresh();
  }
}

final symptomLogsProvider =
    StateNotifierProvider<SymptomLogsNotifier, List<SymptomLog>>((ref) {
      return SymptomLogsNotifier(ref.watch(dailyCareRepositoryProvider));
    });

class SymptomLogsNotifier extends StateNotifier<List<SymptomLog>> {
  SymptomLogsNotifier(this._repository) : super(const []) {
    refresh();
  }

  final DailyCareRepository _repository;

  void refresh() => state = _repository.getAllSymptoms();

  Future<void> add({
    required String name,
    required int severity,
    String? notes,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty || severity < 1 || severity > 5) return;
    await _repository.addSymptom(
      SymptomLog(
        dateTime: DateTime.now(),
        symptomName: cleanName,
        severity: severity,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      ),
    );
    refresh();
  }

  Future<void> delete(SymptomLog log) async {
    await _repository.deleteSymptom(log);
    refresh();
  }
}
