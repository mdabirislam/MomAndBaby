import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'core/database/hive_service.dart';
import 'shared/models/user_profile.dart';

class MomAndBabyApp extends ConsumerWidget {
  const MomAndBabyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileBox = HiveService.getBox<UserProfile>(HiveService.profileBoxName);
    final hasProfile = profileBox.isNotEmpty;

    return MaterialApp(
      title: 'Mom & Baby',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: hasProfile ? const DashboardScreen() : const OnboardingScreen(),
    );
  }
}
