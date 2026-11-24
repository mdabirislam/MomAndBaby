import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/daily_care_providers.dart';
import '../../../../shared/models/daily_care.dart';

class SymptomTrackerScreen extends ConsumerStatefulWidget {
  const SymptomTrackerScreen({super.key});

  @override
  ConsumerState<SymptomTrackerScreen> createState() =>
      _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends ConsumerState<SymptomTrackerScreen> {
  static const _commonSymptoms = [
    'বমি বমি ভাব',
    'বমি',
    'মাথাব্যথা',
    'কোমর ব্যথা',
    'পেটব্যথা',
    'ক্লান্তি',
    'মাথা ঘোরা',
    'ফোলা',
    'অম্বল',
    'অন্যান্য',
  ];

  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedSymptom;
  int _severity = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _selectedSymptom == 'অন্যান্য'
        ? _nameController.text.trim()
        : (_selectedSymptom ?? '');
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('একটি উপসর্গ নির্বাচন বা লিখুন')),
      );
      return;
    }
    await ref
        .read(symptomLogsProvider.notifier)
        .add(name: name, severity: _severity, notes: _notesController.text);
    if (!mounted) return;
    setState(() {
      _selectedSymptom = null;
      _severity = 1;
      _nameController.clear();
      _notesController.clear();
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('উপসর্গের তথ্য সংরক্ষণ হয়েছে')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(symptomLogsProvider);
    final today = DateTime.now();
    final todayLogs = logs
        .where(
          (log) =>
              log.dateTime.year == today.year &&
              log.dateTime.month == today.month &&
              log.dateTime.day == today.day,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('উপসর্গের ডায়েরি')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'আজ কেমন অনুভব করছেন?',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSymptom,
                    decoration: const InputDecoration(
                      labelText: 'উপসর্গ নির্বাচন করুন',
                      border: OutlineInputBorder(),
                    ),
                    items: _commonSymptoms
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSymptom = value),
                  ),
                  if (_selectedSymptom == 'অন্যান্য') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'উপসর্গের নাম',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'অস্বস্তির মাত্রা: $_severity / 5',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: _severity.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_severity',
                    onChanged: (value) =>
                        setState(() => _severity = value.round()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [Text('হালকা'), Text('তীব্র')],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'অতিরিক্ত নোট (ঐচ্ছিক)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('রেকর্ড সংরক্ষণ করুন'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'আজকের রেকর্ড (${todayLogs.length})',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'মোট ${logs.length}টি',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (logs.isEmpty)
            const _EmptySymptoms()
          else
            ...logs.map(
              (log) => _SymptomTile(
                log: log,
                onDelete: () => _confirmDelete(context, log),
              ),
            ),
          const SizedBox(height: 12),
          const _SafetyNote(),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SymptomLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('রেকর্ড মুছবেন?'),
        content: const Text('এই উপসর্গের রেকর্ডটি মুছে ফেলা হবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('মুছুন'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(symptomLogsProvider.notifier).delete(log);
    }
  }
}

class _SymptomTile extends StatelessWidget {
  const _SymptomTile({required this.log, required this.onDelete});
  final SymptomLog log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.secondaryContainer,
          child: Icon(Icons.notes, color: colors.onSecondaryContainer),
        ),
        title: Text(
          log.symptomName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('dd MMM yyyy, hh:mm a').format(log.dateTime)} • মাত্রা ${log.severity}/5',
            ),
            if (log.notes?.isNotEmpty == true) Text(log.notes!),
          ],
        ),
        isThreeLine: log.notes?.isNotEmpty == true,
        trailing: IconButton(
          tooltip: 'রেকর্ড মুছুন',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}

class _EmptySymptoms extends StatelessWidget {
  const _EmptySymptoms();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 28),
    child: Column(
      children: [
        Icon(Icons.health_and_safety_outlined, size: 42),
        SizedBox(height: 8),
        Text('এখনো কোনো উপসর্গ নথিভুক্ত হয়নি'),
      ],
    ),
  );
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.35),
    child: const Padding(
      padding: EdgeInsets.all(14),
      child: Text(
        'এই ডায়েরি শুধু ব্যক্তিগত তথ্য সংরক্ষণের জন্য। তীব্র বা হঠাৎ শুরু হওয়া ব্যথা, রক্তপাত, পানি পড়া, শ্বাসকষ্ট, অজ্ঞান হওয়া বা শিশুর নড়াচড়া কমে গেলে অ্যাপের রেকর্ডের জন্য অপেক্ষা না করে দ্রুত চিকিৎসা নিন।',
      ),
    ),
  );
}
