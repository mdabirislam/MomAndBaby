import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/medicine.dart';
import '../../providers/medicine_providers.dart';

class MedicineListScreen extends ConsumerWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(medicinesProvider);
    final logs = ref.watch(medicineLogsProvider);
    final today = DateTime.now();
    final active = medicines
        .where(
          (medicine) =>
              medicine.isActive &&
              !today.isBefore(
                DateTime(
                  medicine.startDate.year,
                  medicine.startDate.month,
                  medicine.startDate.day,
                ),
              ) &&
              (medicine.endDate == null ||
                  !today.isAfter(
                    DateTime(
                      medicine.endDate!.year,
                      medicine.endDate!.month,
                      medicine.endDate!.day,
                    ),
                  )),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ওষুধের তালিকা'), centerTitle: true),
      body: medicines.isEmpty
          ? _EmptyMedicines(onAdd: () => _showMedicineDialog(context, ref))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TodayMedicineSummary(
                  total: active.fold<int>(
                    0,
                    (sum, medicine) => sum + medicine.reminderTimes.length,
                  ),
                  taken: logs.where((log) => log.scheduledTime != null).length,
                ),
                const SizedBox(height: 16),
                for (final medicine in medicines)
                  _MedicineCard(
                    medicine: medicine,
                    onEdit: () =>
                        _showMedicineDialog(context, ref, medicine: medicine),
                    onToggle: () => ref
                        .read(medicinesProvider.notifier)
                        .toggleMedicineStatus(medicine),
                    onDelete: () => _confirmDelete(context, ref, medicine),
                    onTakeDose: (time) => ref
                        .read(medicineLogsProvider.notifier)
                        .takeMedicine(
                          medicineId: medicine.key.toString(),
                          scheduledTime: time,
                        ),
                    isTaken: (time) => logs.any(
                      (log) =>
                          log.medicineId == medicine.key.toString() &&
                          log.scheduledTime != null &&
                          log.scheduledTime!.hour == time.hour &&
                          log.scheduledTime!.minute == time.minute,
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMedicineDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('ওষুধ যোগ'),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Medicine medicine,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ওষুধ মুছবেন?'),
        content: Text('${medicine.name} এবং এর গ্রহণের লগ মুছে যাবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('মুছুন'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(medicinesProvider.notifier).deleteMedicine(medicine);
      ref.read(medicineLogsProvider.notifier).refresh();
    }
  }

  Future<void> _showMedicineDialog(
    BuildContext context,
    WidgetRef ref, {
    Medicine? medicine,
  }) async {
    final nameController = TextEditingController(text: medicine?.name ?? '');
    final dosageController = TextEditingController(
      text: medicine?.dosage ?? '',
    );
    final now = DateTime.now();
    var startDate =
        medicine?.startDate ?? DateTime(now.year, now.month, now.day);
    var endDate = medicine?.endDate;
    var times = medicine == null
        ? <TimeOfDay>[TimeOfDay.fromDateTime(now)]
        : medicine.reminderTimes
              .map((time) => TimeOfDay(hour: time.hour, minute: time.minute))
              .toList();
    if (times.isEmpty) times.add(TimeOfDay.fromDateTime(now));

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(medicine == null ? 'নতুন ওষুধ' : 'ওষুধ সম্পাদনা'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'ওষুধের নাম'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dosageController,
                    decoration: const InputDecoration(
                      labelText: 'ডোজ / নির্দেশনা (প্রেসক্রিপশন অনুযায়ী)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'গ্রহণের সময়',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  for (var i = 0; i < times.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.alarm_outlined),
                      title: Text(times[i].format(context)),
                      trailing: IconButton(
                        tooltip: 'সময় বাদ দিন',
                        onPressed: times.length == 1
                            ? null
                            : () => setDialogState(() => times.removeAt(i)),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: times[i],
                        );
                        if (picked != null)
                          setDialogState(() => times[i] = picked);
                      },
                    ),
                  TextButton.icon(
                    onPressed: times.length >= 8
                        ? null
                        : () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null)
                              setDialogState(() => times.add(picked));
                          },
                    icon: const Icon(Icons.add),
                    label: const Text('আরেকটি সময় যোগ করুন'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('শুরু'),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(startDate)),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null)
                        setDialogState(() => startDate = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('শেষ (ঐচ্ছিক)'),
                    subtitle: Text(
                      endDate == null
                          ? 'নির্ধারণ করা হয়নি'
                          : DateFormat('dd MMM yyyy').format(endDate!),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (endDate != null)
                          IconButton(
                            onPressed: () =>
                                setDialogState(() => endDate = null),
                            icon: const Icon(Icons.clear),
                          ),
                        const Icon(Icons.calendar_today_outlined),
                      ],
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? startDate,
                        firstDate: startDate,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null)
                        setDialogState(() => endDate = picked);
                    },
                  ),
                  const Text(
                    'সময়গুলো ও ডোজ চিকিৎসকের প্রেসক্রিপশন অনুযায়ী লিখুন। এই অ্যাপ চিকিৎসা নির্দেশনা দেয় না।',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('বাতিল'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    times.isEmpty ||
                    (endDate != null && endDate!.isBefore(startDate)))
                  return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('সংরক্ষণ'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      times.sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
      final reminderTimes = times
          .map((time) => DateTime(2000, 1, 1, time.hour, time.minute))
          .toList();
      if (medicine == null) {
        await ref
            .read(medicinesProvider.notifier)
            .addMedicine(
              Medicine(
                name: nameController.text.trim(),
                dosage: dosageController.text.trim(),
                reminderTimes: reminderTimes,
                startDate: startDate,
                endDate: endDate,
              ),
            );
      } else {
        medicine
          ..name = nameController.text.trim()
          ..dosage = dosageController.text.trim()
          ..reminderTimes = reminderTimes
          ..startDate = startDate
          ..endDate = endDate;
        await ref.read(medicinesProvider.notifier).updateMedicine(medicine);
      }
    }
    nameController.dispose();
    dosageController.dispose();
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.medicine,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.onTakeDose,
    required this.isTaken,
  });

  final Medicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<DateTime> onTakeDose;
  final bool Function(DateTime) isTaken;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: const Icon(Icons.medication_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (medicine.dosage.isNotEmpty)
                        Text(medicine.dosage, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'toggle') onToggle();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                        medicine.isActive ? 'নিষ্ক্রিয় করুন' : 'সক্রিয় করুন',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('মুছে ফেলুন'),
                    ),
                  ],
                ),
              ],
            ),
            if (!medicine.isActive)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Chip(label: Text('নিষ্ক্রিয়')),
              ),
            const Divider(height: 20),
            for (final time in medicine.reminderTimes)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isTaken(time) ? Icons.check_circle : Icons.schedule,
                  color: isTaken(time)
                      ? Colors.green
                      : theme.colorScheme.primary,
                ),
                title: Text(
                  TimeOfDay(
                    hour: time.hour,
                    minute: time.minute,
                  ).format(context),
                ),
                trailing: medicine.isActive
                    ? TextButton(
                        onPressed: isTaken(time)
                            ? null
                            : () => onTakeDose(time),
                        child: Text(isTaken(time) ? 'নথিভুক্ত' : 'নেওয়া হয়েছে'),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _TodayMedicineSummary extends StatelessWidget {
  const _TodayMedicineSummary({required this.total, required this.taken});
  final int total;
  final int taken;

  @override
  Widget build(BuildContext context) {
    final remaining = (total - taken).clamp(0, total);
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.today_outlined, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'আজকের গ্রহণের রেকর্ড',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('$taken / $total টি সময় নথিভুক্ত · বাকি $remaining'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMedicines extends StatelessWidget {
  const _EmptyMedicines({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.medication_outlined, size: 56),
          const SizedBox(height: 12),
          const Text(
            'এখনো কোনো ওষুধ যোগ করা হয়নি',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'চিকিৎসকের নির্দেশ অনুযায়ী ওষুধের নাম ও সময় যোগ করতে পারো।',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('ওষুধ যোগ করুন'),
          ),
        ],
      ),
    ),
  );
}
