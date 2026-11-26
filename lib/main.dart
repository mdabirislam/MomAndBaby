import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/hive_service.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.init();
  await NotificationService.instance.initialize();
  await NotificationService.instance.rescheduleAll();

  runApp(const ProviderScope(child: MomAndBabyApp()));
}
