Mom & Baby — Offline Knowledge Assistant Phase 1 Fix

এই patch-এ Knowledge Assistant repository-এর ভুল PregnancyWeek import path ঠিক করা হয়েছে।
সপ্তাহভিত্তিক ডেটায় চাওয়া সপ্তাহ না থাকলে firstWhere exception না দিয়ে খালি ফলাফল ফেরত দেবে।

করণীয়:
1. ZIP Extract করে project root-এ রাখুন এবং ফাইল overwrite করুন।
2. চালান:
   dart format lib\features\knowledge_assistant\data\knowledge_assistant_repository.dart
   flutter analyze
   flutter test

এই patch app_shell.dart পরিবর্তন করে না। বর্তমান পরিকল্পিত bottom navigation-এ ৫টি tab আছে: হোম, শিশু, যত্ন, পরিকল্পনা, আরও।
