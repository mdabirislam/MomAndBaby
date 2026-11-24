Mom & Baby — Daily Care Phase 1 Patch

Apply this patch to the project root:
H:\ABIR\dart project\pregnancy_care

Extract the ZIP and allow overwrite for the listed existing files. It adds:
- A symptom diary screen with common symptoms, custom symptom name, subjective severity (1–5), optional notes, history, and delete.
- Repository/provider methods using the existing Hive symptomBox.
- A revised water tracker with manual 150/250/500 ml entries and today's recorded total. It does not prescribe a universal daily water target.
- A safety clarification in the kick counter: it stores personal sessions only and does not set a universal movement target.
- A Care tab entry point for the symptom diary.

Database compatibility:
- No Hive type IDs, field indices, adapters, or existing stored records are changed.
- Existing WaterLog, KickCount, and SymptomLog models are reused.

After extraction, run from Windows CMD:
  dart format lib\features\daily_care lib\features\navigation\presentation\app_shell.dart
  flutter analyze
  flutter test

The patch has not been compiled in this environment because Flutter/Dart SDK is unavailable here. Run the commands above locally and share the output for any required fixes.
