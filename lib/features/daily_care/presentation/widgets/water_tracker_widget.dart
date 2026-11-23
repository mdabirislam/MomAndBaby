import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/daily_care_providers.dart';
import '../../../../core/constants/colors.dart';

class WaterTrackerWidget extends ConsumerWidget {
  const WaterTrackerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayWater = ref.watch(todayWaterProvider);
    const goal = 2500; // 2.5 Liters goal
    final progress = (todayWater / goal).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$todayWater মিলি',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text(
                  'লক্ষ্য: $goal মিলি',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                ref.read(todayWaterProvider.notifier).addWater(250); // Add a glass (250ml)
              },
              icon: const Icon(Icons.add_circle, size: 40, color: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 15),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.blue[50],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[300]!),
          minHeight: 12,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}
