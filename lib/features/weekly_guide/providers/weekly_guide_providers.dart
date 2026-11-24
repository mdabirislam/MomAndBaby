import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/weekly_guide_repository.dart';
import '../domain/pregnancy_week.dart';

final weeklyGuideRepositoryProvider = Provider(
  (ref) => WeeklyGuideRepository(),
);

final weeklyGuideProvider = FutureProvider.family<PregnancyWeek?, int>((
  ref,
  week,
) async {
  final repo = ref.watch(weeklyGuideRepositoryProvider);
  return await repo.getWeek(week);
});
