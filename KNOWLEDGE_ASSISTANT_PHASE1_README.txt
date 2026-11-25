Mom & Baby — Offline Knowledge Assistant Phase 1

What this patch adds
- Bangla/English offline keyword search over a curated local pregnancy FAQ file.
- Week 1–40 answers reuse the existing pregnancy_weeks.json data.
- Intent-based week sections: baby development, mother changes, nutrition, discomforts, danger signs, and size/weight.
- No network/API is used for search or answers. Source links open externally only when the user taps them.
- A persistent urgent-warning panel and explicit non-diagnostic limitations.
- Entry point under More > জ্ঞান সহায়ক.

Files added
- assets/data/pregnancy_faq_bn.json
- lib/features/knowledge_assistant/domain/knowledge_answer.dart
- lib/features/knowledge_assistant/data/knowledge_assistant_repository.dart
- lib/features/knowledge_assistant/presentation/knowledge_assistant_screen.dart
- test/features/knowledge_assistant/knowledge_assistant_repository_test.dart

File modified
- lib/features/navigation/presentation/app_shell.dart

No dependencies, Hive adapters, Hive type IDs, or existing database fields were changed.

Important clinical note
FAQ content is a first-pass educational dataset based on linked NHS/ACOG public guidance. The project's 40-week JSON currently marks its content as research_checked_pending_clinician_review. This module is not a diagnostic or prescribing system and must receive qualified clinician review before production distribution. Do not use it as a substitute for local maternity services.

Apply
1. Extract this ZIP into the Flutter project root and overwrite the one modified file.
2. Run:
   dart format lib\features\knowledge_assistant lib\features\navigation\presentation\app_shell.dart test\features\knowledge_assistant
   flutter analyze
   flutter test
