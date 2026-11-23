import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weekly_guide_providers.dart';

class WeeklyGuideScreen extends ConsumerWidget {
  final int week;

  const WeeklyGuideScreen({super.key, required this.week});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekDataAsync = ref.watch(weeklyGuideProvider(week));

    return Scaffold(
      appBar: AppBar(title: Text('$weekতম সপ্তাহ')),
      body: weekDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          if (data == null) return const Center(child: Text('তথ্য পাওয়া যায়নি'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('শিশুর বেড়ে ওঠা', data.babyDevelopment),
                _buildSection('মায়ের শরীরের পরিবর্তন', data.motherBodyChanges),
                _buildSection('খাবার ও পুষ্টি', data.dietToEat),
                _buildSection('বিপদের লক্ষণ', data.dangerSigns),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}
