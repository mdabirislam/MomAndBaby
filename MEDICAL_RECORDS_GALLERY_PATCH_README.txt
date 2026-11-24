MOM & BABY — MEDICAL RECORDS GALLERY PATCH

What this patch changes:
- Copies selected report images into the app's private documents directory so temporary picker paths do not expire.
- Supports selecting multiple images from gallery and capturing one image with camera.
- Adds optional notes and a clearer category/title form.
- Shows image thumbnails, record details, and zoomable multi-image viewing.
- Confirms before deleting a record and deletes only files inside this app's own medical_records directory. Existing external file paths are never deleted.
- Keeps the existing MedicalRecord Hive model, typeId=8, and all field indices unchanged. No database migration is required.

Apply by extracting this ZIP into the Flutter project root. Existing records remain in Hive. Old records that point to external temporary paths may still show a missing image if the source file was already removed; this patch cannot recover deleted files.

Then run:
flutter pub get
dart format lib\features\medical_records
flutter analyze
flutter test

This version stores image attachments only. PDF/document picker support is a separate follow-up.
