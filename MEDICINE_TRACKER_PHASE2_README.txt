Mom & Baby — Daily Care Phase 2 (Medicine Tracker + Daily Summary)

Apply
1. Extract this ZIP into the Flutter project root:
   H:\ABIR\dart project\pregnancy_care
2. Allow the listed files to overwrite existing files.
3. Run:
   dart format lib\shared\models\medicine.dart lib\shared\models\medicine.g.dart lib\features\medicines lib\features\daily_care\presentation\widgets\daily_summary_card.dart lib\features\navigation\presentation\app_shell.dart
   flutter analyze
   flutter test

What changed
- Medicine add/edit/delete and active/inactive status.
- Multiple daily schedule times and optional start/end dates.
- Individual scheduled-dose logging; duplicate logging for the same medicine/time/day is blocked.
- Daily Care summary card: water, symptoms, kick sessions and medicine logs.
- MedicineLog gained nullable Hive field 2 (scheduledTime). Existing typeId=5 and fields 0-1 are unchanged. Old records without field 2 remain readable.
- Deleting a medicine also deletes its associated logs.

Important limitations
- This patch records schedules and manually marked doses. It does NOT yet schedule Android notifications. Notification permission, timezone-safe scheduling, reboot handling and Android 13+ checks will be implemented and tested as a separate reminder milestone.
- The app does not prescribe medicine or dosage. Enter only the schedule supplied by the user's clinician.
- Kick tracking is a personal log, not a universal target or a substitute for clinical advice.

Validation
This patch was reviewed against the supplied MomAndBaby-main (3).zip source and the previously applied Daily Care Phase 1 patch. Flutter/Dart SDK is not available in the patch-building environment; run the commands above locally and share any output before treating it as verified.
