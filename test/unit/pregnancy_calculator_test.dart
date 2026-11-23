import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_care/core/services/pregnancy_calculator.dart';

void main() {
  group('PregnancyCalculator Tests', () {
    test('EDD Calculation (LMP + 280 days)', () {
      final lmp = DateTime(2024, 1, 1);
      final edd = PregnancyCalculator.calculateEDD(lmp);
      expect(edd, DateTime(2024, 10, 7)); // Jan 1 + 280 days = Oct 7
    });

    test('Leap Year Handling', () {
      final lmp = DateTime(2024, 2, 1); // 2024 is a leap year
      final edd = PregnancyCalculator.calculateEDD(lmp);
      expect(edd, DateTime(2024, 11, 7));
    });

    test('Trimester Boundaries', () {
      final lmp = DateTime.now();
      
      // Week 1 -> Trimester 1
      expect(PregnancyCalculator.currentTrimester(lmp), 1);
      
      // Week 14 -> Trimester 2
      final lmpTrimester2 = DateTime.now().subtract(const Duration(days: 14 * 7));
      expect(PregnancyCalculator.currentTrimester(lmpTrimester2), 2);
      
      // Week 28 -> Trimester 3
      final lmpTrimester3 = DateTime.now().subtract(const Duration(days: 28 * 7));
      expect(PregnancyCalculator.currentTrimester(lmpTrimester3), 3);
    });

    test('Dates Beyond 40 Weeks', () {
      final lmp = DateTime.now().subtract(const Duration(days: 41 * 7));
      final week = PregnancyCalculator.currentWeek(lmp);
      expect(week, 42);
      final progress = PregnancyCalculator.progressPercentage(lmp);
      expect(progress, 1.0); // Should clamp to 1.0
    });
  });
}
