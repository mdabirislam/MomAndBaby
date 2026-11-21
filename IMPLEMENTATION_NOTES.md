# IMPLEMENTATION_NOTES.md

## Architecture
- **Pattern:** Clean Feature-First Architecture.
- **State Management:** Riverpod.
- **Database:** Hive (Local, offline-first).
- **UI:** Flutter with Bengali typography (Hind Siliguri, Noto Sans Bengali).

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
    database/
    notifications/
    widgets/
  features/
    onboarding/
    dashboard/
    pregnancy/
    weekly_guide/
    daily_care/
    medicines/
    appointments/
    diary/
    medical_records/
    emergency/
    settings/
  shared/
    models/
    providers/
    widgets/
assets/
  data/
  animations/
  images/
  icons/
  fonts/
```

## Key Logic & Calculations
- **Pregnancy Calculator:** LMP based (280 days), Ultrasound adjustment, weeks/days/trimester/progress.
- **Offline-first:** All data in Hive. Images in app-private storage.

## Dependency Decisions
- `flutter_riverpod`: State management.
- `hive_ce`: Modern Hive fork (considering current state of Hive).
- `intl`: Localization and date formatting.
- `google_fonts`: Bengali fonts.
- `lottie`: Animations.
- `flutter_local_notifications`: Reminders.
- `image_picker`: Medical records.
- `path_provider`: File storage.
- `local_auth`: Biometric lock.
- `cryptography`: Backup encryption.

## Resuming Development
1. Run `flutter pub get`
2. Run `dart run build_runner build`
