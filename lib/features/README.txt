Medical Records feature patch

Extract this ZIP into:
H:\ABIR\dart project\pregnancy_care\lib\features

Allow overwrite of the three files under lib\features\medical_records.

Fixes:
1. Corrected the provider import path in the screen.
2. Delete uses the actual Hive MedicalRecord object rather than the visible sorted-list index.
   This prevents deleting the wrong record when records are sorted by date.

Then run from project root:
dart format lib\features\medical_records
flutter analyze
flutter test

This patch does not change Hive typeId or field numbers.
