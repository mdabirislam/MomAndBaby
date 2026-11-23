import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/medical_record_providers.dart';

class MedicalRecordListScreen extends ConsumerWidget {
  const MedicalRecordListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(medicalRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('মেডিকেল রেকর্ডস'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(
                Icons.file_present,
                color: Colors.pinkAccent,
                size: 36,
              ),
              title: Text(
                record.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${record.category} • ${DateFormat('dd MMM, yyyy').format(record.date)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  ref
                      .read(medicalRecordsProvider.notifier)
                      .deleteRecord(record);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(context, ref),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    String selectedCategory = 'আল্ট্রাসাউন্ড';
    final categories = [
      'আল্ট্রাসাউন্ড',
      'রক্তের পরীক্ষা',
      'প্রেসক্রিপশন',
      'অন্যান্য',
    ];
    final ImagePicker picker = ImagePicker();
    List<String> pickedPaths = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('নতুন রেকর্ড যোগ করুন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'শিরোনাম'),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedCategory = val);
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      pickedPaths.add(image.path);
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: Text(
                  pickedPaths.isEmpty
                      ? 'ছবি বেছে নিন'
                      : '${pickedPaths.length}টি ছবি যুক্ত হয়েছে',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  ref
                      .read(medicalRecordsProvider.notifier)
                      .addRecord(
                        titleController.text,
                        selectedCategory,
                        pickedPaths,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('সংরক্ষণ করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
