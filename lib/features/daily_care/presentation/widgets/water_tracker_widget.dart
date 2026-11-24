import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/daily_care_providers.dart';

class WaterTrackerWidget extends ConsumerWidget {
  const WaterTrackerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(todayWaterProvider);
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Icon(Icons.water_drop_outlined, color: colors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'আজকের পানি পান',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text('আজ কতটুকু পানি পান করেছেন তা লিখে রাখুন'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '$total মিলি',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'আজকের মোট নথিভুক্ত পরিমাণ',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _AddWaterButton(ml: 150),
            _AddWaterButton(ml: 250),
            _AddWaterButton(ml: 500),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'পানির প্রয়োজন ব্যক্তিভেদে ও চিকিৎসকের পরামর্শ অনুযায়ী ভিন্ন হতে পারে। এখানে কোনো নির্দিষ্ট দৈনিক লক্ষ্য নির্ধারণ করা হয়নি।',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _AddWaterButton extends ConsumerWidget {
  const _AddWaterButton({required this.ml});

  final int ml;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => ref.read(todayWaterProvider.notifier).addWater(ml),
      icon: const Icon(Icons.add, size: 18),
      label: Text('$ml ml'),
    );
  }
}
