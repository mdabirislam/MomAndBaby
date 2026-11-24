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
- [x] Daily Care: Water logging and kick-session logging (personal records only)
- [ ] Daily Care: Symptom diary with severity, notes, history, and delete (implemented; awaiting local verification)
- [x] Medicine List & Logging
- [x] Pregnancy Diary (Text entries)
- [x] Emergency Contacts Screen with Calling
- [x] Reusable Bengali UI Components & Theming

## In Progress
- [ ] Daily Care: local analyze/test verification and UI/device review
- [ ] Daily Care polish: history filters and summary
- [ ] Medical Records Gallery (Image & Doc Store)

## Pending Features
- [ ] Medicine & Appointment Reminders (Local Notifications)
- [ ] App Lock / Biometric Security
- [ ] Backup & Restore (Encrypted JSON Export/Import)
- [ ] Home Screen Widget (Android AppWidget Integration)

## Known Bugs / Issues
- CLI commands (`flutter`, `dart`) time out in the current automated environment shell integration, but manually executing them in a local PowerShell window works fine.

## Last Completed Task
- Added symptom logging and connected it to the Care tab; improved water logging UI and safety copy for movement records.

## Next Task
- Verify Daily Care on a real Flutter toolchain, then implement the remaining Care history/summary needs.

