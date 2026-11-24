Mom & Baby — Pregnancy Memory Journal patch

Apply: extract this ZIP into the Flutter project root (H:\ABIR\dart project\pregnancy_care), preserving folders and replacing files.

Features:
- Create and edit diary memories
- Mood selection and optional pregnancy-week label (1–42)
- Add multiple photos from gallery or camera; photos are copied into app-private documents storage
- Remove photos while editing; clean up removed/abandoned image files
- Search diary text/mood and filter by mood
- Delete diary entries with confirmation
- Existing DiaryEntry Hive typeId 7 and field indexes 0–3 are preserved; pregnancyWeek is appended as field 4
- Repository update/delete now use the Hive object itself, avoiding sorted-list index mismatch

After applying, run from project root:
  flutter pub get
  dart format lib\shared\models\diary_entry.dart lib\shared\models\diary_entry.g.dart lib\features\diary
  flutter analyze
  flutter test

No new package dependency is required; image_picker and path_provider are already in pubspec.yaml.
