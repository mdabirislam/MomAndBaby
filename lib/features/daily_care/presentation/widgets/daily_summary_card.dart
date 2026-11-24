import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../medicines/providers/medicine_providers.dart';
import '../../providers/daily_care_providers.dart';

class DailySummaryCard extends ConsumerWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final water = ref.watch(todayWaterProvider);
    final symptoms = ref.watch(symptomLogsProvider);
    final kicks = ref.watch(kickCounterProvider);
    final medicineLogs = ref.watch(medicineLogsProvider);
    final today = DateTime.now();
    final todaySymptoms = symptoms
        .where(
          (item) =>
              item.dateTime.year == today.year &&
              item.dateTime.month == today.month &&
              item.dateTime.day == today.day,
        )
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'আজকের সারাংশ',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.water_drop_outlined,
                    label: 'পানি',
                    value: '$water ml',
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.monitor_heart_outlined,
                    label: 'উপসর্গ',
                    value: '$todaySymptoms',
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.directions_walk_outlined,
                    label: 'নড়াচড়ার সেশন',
                    value: '${kicks.length}',
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.medication_outlined,
                    label: 'ওষুধের লগ',
                    value:
                        '${medicineLogs.where((log) => log.scheduledTime != null).length}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'এটি শুধু সংরক্ষিত তথ্যের সারাংশ; কোনো স্বাস্থ্য মূল্যায়ন বা চিকিৎসা নির্দেশনা নয়.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}
