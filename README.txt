Mom & Baby - Android startup crash diagnostic patch

Replace your project's pubspec.yaml with the included pubspec.yaml.
This removes the unused home_widget dependency. The uploaded project
has no Dart references to HomeWidget, while this dependency brings
Jetpack Glance/AndroidX WorkManager into the Android app. The crash
log shows WorkManager's WorkDatabase failing during AndroidX Startup.

Then run from the project root:
  flutter pub get
  flutter clean
  flutter build apk --release

This patch changes only pubspec.yaml. Keep a backup of your current
pubspec.yaml before replacing it. No app data on the phone is touched.
