# IMPLEMENTATION_NOTES.md

## Architecture
- **Pattern:** Clean Feature-First Architecture.
- **State Management:** Riverpod.
- **Database:** Hive (Local, offline-first).
- **UI:** Flutter with Bengali typography (Hind Siliguri via Google Fonts).

## Folder Structure
```
lib/
  main.dart
  app.dart
  core/
    constants/
    theme/
    utils/
    services/
      pregnancy_calculator.dart
    database/
      hive_service.dart
  features/
    onboarding/
      presentation/
        onboarding_screen.dart
    dashboard/
      presentation/
        dashboard_screen.dart
      providers/
        dashboard_providers.dart
      widgets/
        dashboard_card.dart
    weekly_guide/
      domain/
        pregnancy_week.dart
      data/
        weekly_guide_repository.dart
      providers/
        weekly_guide_providers.dart
      presentation/
        weekly_guide_screen.dart
        weekly_guide_selector.dart
  shared/
    models/
      user_profile.dart
      daily_care.dart
      medicine.dart
      appointment.dart
      diary_entry.dart
      medical_record.dart
    providers/
      user_provider.dart
assets/
  data/
    pregnancy_weeks.json
```

## Key Logic & Calculations
- **Pregnancy Calculator:** LMP based (280 days standard), supports progress %, week/day Breakdown, Trimester boundaries (1-13, 14-26, 27+), and leap year date arithmetic.
- **Offline-First:** All user details stored locally in Hive boxes initialized via `HiveService`.
- **Weekly Guide Data:** Loaded via `rootBundle` from `assets/data/pregnancy_weeks.json` into typed `PregnancyWeek` models.

## Unit Testing
- Unit tests written under `test/unit/pregnancy_calculator_test.dart` for calculations, boundaries, and leap years.

## Resuming Development
1. Run `flutter pub get`
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Run `flutter run`

