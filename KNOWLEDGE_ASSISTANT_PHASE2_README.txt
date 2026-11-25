Mom & Baby — Offline Knowledge Assistant Phase 2

Files in this patch:
- lib/features/knowledge_assistant/data/knowledge_assistant_repository.dart
- lib/features/knowledge_assistant/presentation/knowledge_assistant_screen.dart
- test/features/knowledge_assistant/knowledge_assistant_repository_test.dart

Changes:
1. Expanded Bangla/English synonym matching for common pregnancy topics.
2. Improved scoring for exact title/question phrases and keyword matches.
3. Bengali week digits are normalized, so queries such as “১২ সপ্তাহে শিশুর বিকাশ” work.
4. Recent searches (last 8) are stored locally on this device.
5. Users can optionally save unanswered questions (last 30) for later review.
6. Recent/unanswered lists can be cleared.
7. No new dependency, API, internet requirement, Hive schema, or migration.

Apply: extract at project root and overwrite matching files. Then run:
  dart format lib\features\knowledge_assistant test\features\knowledge_assistant
  flutter analyze
  flutter test

Note: This patch has not been run with Flutter SDK in the patch-generation environment. It must be validated in the user's project.
