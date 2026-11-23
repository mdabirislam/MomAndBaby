# DEVELOPMENT_STATUS.md

## Project Overview
**Project Name:** Mom & Baby (মা ও শিশু)
**Objective:** A private, offline-first pregnancy companion app in Bengali.
**Status:** Core features implemented & integrated.

## Completed Features
- [x] Project Initialization & Architecture Setup
- [x] Hive Database Setup & Model Generation
- [x] Pregnancy Calculation Engine (`PregnancyCalculator`)
- [x] Unit Tests for Calculation Engine
- [x] Onboarding Flow (LMP & User Profile)
- [x] Main Dashboard with Pregnancy Progress
- [x] Weekly Pregnancy Knowledge Base (JSON Data + Domain Models)
- [x] Weekly Guide Screen & Horizontal Week Selector UI
- [x] Daily Care Trackers (Water Tracker, Kick Counter)
- [x] Medicine List & Logging
- [x] Pregnancy Diary (Text entries)
- [x] Emergency Contacts Screen with Calling
- [x] Reusable Bengali UI Components & Theming

## In Progress
- [ ] Medical Records Gallery (Image & Doc Store)

## Pending Features
- [ ] Medicine & Appointment Reminders (Local Notifications)
- [ ] App Lock / Biometric Security
- [ ] Backup & Restore (Encrypted JSON Export/Import)
- [ ] Home Screen Widget (Android AppWidget Integration)

## Known Bugs / Issues
- CLI commands (`flutter`, `dart`) time out in the current automated environment shell integration, but manually executing them in a local PowerShell window works fine.

## Next Task
- Implement Medical Records Gallery and local image storage.

