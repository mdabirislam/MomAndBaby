import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/daily_care_repository.dart';
import '../../../shared/models/daily_care.dart';

final dailyCareRepositoryProvider = Provider((ref) => DailyCareRepository());

final todayWaterProvider = StateNotifierProvider<TodayWaterNotifier, int>((ref) {
  return TodayWaterNotifier(ref.watch(dailyCareRepositoryProvider));
});

class TodayWaterNotifier extends StateNotifier<int> {
  final DailyCareRepository _repository;

  TodayWaterNotifier(this._repository) : super(0) {
    refresh();
  }

  void refresh() {
    state = _repository.getTotalWaterForDate(DateTime.now());
  }

  Future<void> addWater(int ml) async {
    final log = WaterLog(date: DateTime.now(), amountMl: ml);
    await _repository.addWater(log);
    refresh();
  }
}

final kickCounterProvider = StateNotifierProvider<KickCounterNotifier, List<KickCount>>((ref) {
  return KickCounterNotifier(ref.watch(dailyCareRepositoryProvider));
});

class KickCounterNotifier extends StateNotifier<List<KickCount>> {
  final DailyCareRepository _repository;

  KickCounterNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.getKickCountsForDate(DateTime.now());
  }

  Future<void> saveSession(int count, Duration duration) async {
    final log = KickCount(
      startTime: DateTime.now().subtract(duration),
      count: count,
      duration: duration,
    );
    await _repository.addKickCount(log);
    refresh();
  }
}
