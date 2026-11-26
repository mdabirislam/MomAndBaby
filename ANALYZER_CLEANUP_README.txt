Mom & Baby — Flutter 3.50 Material UI + Analyzer Info Cleanup

Apply this patch by extracting its contents into the Flutter project root:
H:\ABIR\dart project\pregnancy_care
Allow files to be replaced.

Then run:
  flutter pub get
  dart format lib test
  flutter analyze
  flutter test

Changes:
- Migrates app and widget-test imports from package:flutter/material.dart to the official package:material_ui/material_ui.dart.
- Adds material_ui ^1.11.1 to pubspec.yaml.
- Preserves the warm cream scaffold background while removing deprecated ColorScheme.background.
- Replaces deprecated DropdownButtonFormField.value with initialValue.
- Fixes curly-brace and unnecessary-underscore lints shown in the supplied analyzer output.
- Includes the previous Weekly Guide import/model/provider fixes and removes its unused import.

Note: pubspec.lock is intentionally not included; flutter pub get will resolve material_ui and update the lockfile for this machine.
