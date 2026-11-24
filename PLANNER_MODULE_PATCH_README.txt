Mom & Baby — Planner Module Patch

Apply:
1. Extract this ZIP into the Flutter project root (the folder containing pubspec.yaml).
2. Allow files to merge/overwrite when prompted.
3. Run:

   dart format lib\core\database\hive_service.dart lib\core\notifications\notification_service.dart lib\features\navigation\presentation\app_shell.dart lib\features\planner lib\shared\models\planner_task.dart lib\shared\models\planner_task.g.dart
   flutter analyze
   flutter test

Included:
- Pregnancy timeline calculated from the saved LMP and optional EDD override.
- Existing doctor appointments surfaced in Planner; existing appointment storage/reminders are reused.
- Persistent hospital-bag and delivery-preparation checklists.
- Custom tasks and test/scan schedule entries, with optional date, notes and notification reminder.
- Planner tasks stored offline in a new Hive box.

Data compatibility:
- Existing Hive type IDs 0–8 and their field indices are unchanged.
- New PlannerTask uses typeId 9. Existing boxes are not cleared or migrated.
- Checklist entries are seeded once by stable template IDs.

Notes:
- Notification delivery depends on Android notification/exact-alarm permissions and device battery settings.
- Test/scan timing must be entered according to the user's clinician's advice; the app does not prescribe a test schedule.
- This patch was source-reviewed only in this environment; run the commands above on the project machine and share the complete output if any issue appears.
