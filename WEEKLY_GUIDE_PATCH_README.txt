MOM & BABY — WEEKLY GUIDE / BABY DEVELOPMENT PATCH

Apply this patch to the project root:
H:\ABIR\dart project\pregnancy_care

Extract the ZIP into the project root and allow the four files to be replaced/added.

Files:
- assets/data/pregnancy_weeks.json
  Complete dataset for weeks 1–40. Approximate fruit/size/weight claims have been replaced with clear
  caveats where a reliable week-specific measurement is not supplied.
- lib/features/weekly_guide/data/weekly_guide_repository.dart
  Validates that all 40 weeks exist exactly once and safely returns null for out-of-range requests.
- lib/features/weekly_guide/presentation/weekly_guide_screen.dart
  New responsive week guide with week dropdown, previous/next navigation, trimester indicator,
  baby development, maternal changes, nutrition, care tips, warning signs, and source links.
- test/weekly_guide_data_test.dart
  Regression tests for all 40 weeks and required fields.

After extraction, run:

dart format lib\features\weekly_guide test\weekly_guide_data_test.dart
flutter analyze
flutter test

Medical content note:
Content is educational and based on ACOG and NHS pregnancy-development guidance. It is NOT
clinician-reviewed or individualized medical advice. The app clearly displays this status.
Do not use the app to diagnose or replace antenatal care.
