import 'package:flutter_test/flutter_test.dart';

import 'package:pregnancy_care/features/weekly_guide/data/weekly_guide_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Weekly pregnancy guide data', () {
    test('contains every week from 1 through 40 exactly once', () async {
      final weeks = await WeeklyGuideRepository().loadAllWeeks();

      expect(weeks, hasLength(40));
      expect(
        weeks.map((item) => item.week).toList(),
        List<int>.generate(40, (index) => index + 1),
      );
    });

    test('each week has the core educational sections', () async {
      final weeks = await WeeklyGuideRepository().loadAllWeeks();

      for (final week in weeks) {
        expect(week.babyDevelopment.trim(), isNotEmpty);
        expect(week.motherBodyChanges.trim(), isNotEmpty);
        expect(week.dangerSigns.trim(), isNotEmpty);
        expect(week.dietToEat.trim(), isNotEmpty);
        expect(week.lifestyleTips.trim(), isNotEmpty);
      }
    });

    test('returns null for a week outside the supported range', () async {
      final repository = WeeklyGuideRepository();

      expect(await repository.getWeek(0), isNull);
      expect(await repository.getWeek(41), isNull);
    });
  });
}
