import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/medicine_providers.dart';
import '../../../../shared/models/medicine.dart';

class MedicineListScreen extends ConsumerWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(medicinesProvider);
    final logs = ref.watch(medicineLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ওষুধের তালিকা'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final medicine = medicines[index];
          final isTakenToday = logs.any((log) => log.medicineId == medicine.key.toString());

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${medicine.dosage} - ${medicine.reminderTimes.map((t) => DateFormat('hh:mm a').format(t)).join(", ")}'),
              trailing: IconButton(
                icon: Icon(
                  isTakenToday ? Icons.check_circle : Icons.circle_outlined,
                  color: isTakenToday ? Colors.green : Colors.grey,
                  size: 30,
                ),
                onPressed: () {
                  if (!isTakenToday) {
                    ref.read(medicineLogsProvider.notifier).takeMedicine(medicine.key.toString());
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicineDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নতুন ওষুধ যোগ করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'ওষুধের নাম')),
            TextField(controller: dosageController, decoration: const InputDecoration(labelText: 'ডোজ (যেমন: ১টি করে ২ বার)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newMed = Medicine(
                  name: nameController.text,
                  dosage: dosageController.text,
                  reminderTimes: [DateTime.now()], // Simplification for now
                  startDate: DateTime.now(),
                );
                ref.read(medicinesProvider.notifier).addMedicine(newMed);
                Navigator.pop(context);
              }
            },
            child: const Text('যোগ করুন'),
          ),
        ],
      ),
    );
  }
}
