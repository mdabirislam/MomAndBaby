import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/navigation/presentation/app_shell.dart';
import 'shared/providers/user_provider.dart';

class MomAndBabyApp extends ConsumerWidget {
  const MomAndBabyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final hasProfile = profile != null;

    return MaterialApp(
      title: 'মায়ের যত্ন',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: hasProfile ? const AppShell() : const OnboardingScreen(),
    );
  }
}
