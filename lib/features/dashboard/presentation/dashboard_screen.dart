import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/user_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('মা ও শিশু'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('স্বাগতম, ${profile?.name ?? 'মা'}'),
            const SizedBox(height: 20),
            const Text('আপনার গর্ভকালীন ড্যাশবোর্ড শীঘ্রই এখানে আসবে।'),
          ],
        ),
      ),
    );
  }
}
