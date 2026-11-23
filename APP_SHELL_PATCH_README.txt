Mom & Baby - App Shell patch

This patch adds the first persistent five-tab navigation shell and routes the existing dashboard through it.

Files:
1) lib/app.dart (updated)
2) lib/features/navigation/presentation/app_shell.dart (new)

Apply:
- Extract this ZIP into the Flutter project root:
  H:\ABIR\dart project\pregnancy_care
- Allow overwrite for lib/app.dart.
- New navigation file will be created automatically.

Then run from project root:
  flutter pub get
  dart format lib/app.dart lib/features/navigation/presentation/app_shell.dart
  flutter analyze
  flutter test

Notes:
- Existing onboarding is retained.
- Existing Dashboard, Weekly Guide, Water Tracker, Medicine, Kick Counter, Diary and Emergency screens are reused.
- Planner and Our Space are navigation placeholders, not implemented features yet. Medical Records integration is intentionally left for its own milestone so the post-ZIP local work can be integrated safely.
- No Hive model, typeId, field number, or database data was changed.
