Mom & Baby — Personal Companion / Our Space Patch

Included:
- New offline Our Space notes: title, message, author label, category, date.
- Create, edit, delete, search, category filter, and pin/unpin notes.
- Replaces the More tab's Our Space placeholder with the working screen.
- Adds Hive model typeId 10 and a dedicated companionNoteBox.

Important:
- Existing Hive type IDs and field numbers are unchanged.
- This is local-device storage only. It does not sync between two phones and author labels are not authenticated accounts.
- The existing Pregnancy Memory Journal remains separate; this module is for shared messages, support notes, and small plans.

Apply:
1. Extract the ZIP into the Flutter project root and allow file replacement.
2. Run:
   dart format lib\core\database\hive_service.dart lib\features\navigation\presentation\app_shell.dart lib\features\companion lib\shared\models\companion_note.dart lib\shared\models\companion_note.g.dart
   flutter analyze
   flutter test

Please share the full analyze/test output if any issue appears.
