import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import 'core/database/hive_service.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Hive
      await HiveService.init();
      await NotificationService.instance.initialize();

      // Schedule notifications after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.instance.rescheduleAll();
      });

      runApp(const ProviderScope(child: MomAndBabyApp()));
    },
    (error, stack) {
      debugPrint('Startup Error: $error\n$stack');
    },
  );
}
