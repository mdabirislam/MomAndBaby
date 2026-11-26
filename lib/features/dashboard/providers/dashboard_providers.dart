import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/user_provider.dart';
import '../../../core/services/pregnancy_calculator.dart';

final pregnancyProgressProvider = Provider<Map<String, dynamic>>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null) return {};

  final lmp = profile.lmp;
  return {
    'week': PregnancyCalculator.currentWeek(lmp),
    'day': PregnancyCalculator.currentDayInWeek(lmp),
    'progress': PregnancyCalculator.progressPercentage(lmp),
    'remainingDays': PregnancyCalculator.remainingDays(lmp),
  };
});
