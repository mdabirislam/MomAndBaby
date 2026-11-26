import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/medical_record.dart';
import '../../providers/medical_record_providers.dart';

class MedicalRecordListScreen extends ConsumerWidget {
  const MedicalRecordListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(medicalRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('মেডিকেল রেকর্ডস'), centerTitle: true),
      body: records.isEmpty
          ? _EmptyRecordsState(onAdd: () => _showAddRecordDialog(context, ref))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = records[index];
                return _RecordCard(
                  record: record,
                  onTap: () => _showRecordDetails(context, record),
                  onDelete: () => _confirmDelete(context, ref, record),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('রেকর্ড যোগ করুন'),
      ),
    );
  }

  Future<void> _showAddRecordDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    final picker = ImagePicker();
    final pickedImages = <XFile>[];
    const categories = [
      'আল্ট্রাসাউন্ড',
      'রক্তের পরীক্ষা',
      'প্রেসক্রিপশন',
      'অন্যান্য',
    ];
    var selectedCategory = categories.first;
    var isSaving = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !isSaving,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('নতুন মেডিকেল রেকর্ড'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    onChanged: (_) => setDialogState(() {}),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'রেকর্ডের শিরোনাম *',
                      hintText: 'যেমন: ১২ সপ্তাহের আল্ট্রাসাউন্ড',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'ধরন'),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'নোট (ঐচ্ছিক)',
                      hintText: 'রিপোর্ট সম্পর্কে প্রয়োজনীয় তথ্য',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final images = await picker.pickMultiImage(
                                    imageQuality: 88,
                                  );
                                  if (images.isNotEmpty) {
                                    setDialogState(() {
                                      for (final image in images) {
                                        if (!pickedImages.any(
                                          (item) => item.path == image.path,
                                        )) {
                                          pickedImages.add(image);
                                        }
                                      }
                                    });
                                  }
                                },
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('গ্যালারি'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        tooltip: 'ক্যামেরা',
                        onPressed: isSaving
                            ? null
                            : () async {
                                final image = await picker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 88,
                                );
                                if (image != null) {
                                  setDialogState(() => pickedImages.add(image));
                                }
                              },
                        icon: const Icon(Icons.camera_alt_outlined),
                      ),
                    ],
                  ),
                  if (pickedImages.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${pickedImages.length}টি ছবি নির্বাচিত'),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: pickedImages.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(pickedImages[index].path),
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: InkWell(
                                onTap: () => setDialogState(
                                  () => pickedImages.removeAt(index),
                                ),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  const Text(
                    'ছবিগুলো অ্যাপের নিজস্ব স্টোরেজে কপি করে রাখা হবে।',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: const Text('বাতিল'),
              ),
              FilledButton(
                onPressed: isSaving || titleController.text.trim().isEmpty
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await ref
                              .read(medicalRecordsProvider.notifier)
                              .addRecord(
                                titleController.text.trim(),
                                selectedCategory,
                                List<XFile>.from(pickedImages),
                                notes: notesController.text.trim().isEmpty
                                    ? null
                                    : notesController.text.trim(),
                              );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        } catch (error) {
                          setDialogState(() => isSaving = false);
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('সংরক্ষণ করা যায়নি: $error'),
                              ),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('সংরক্ষণ'),
              ),
            ],
          ),
        ),
      );
    } finally {
      titleController.dispose();
      notesController.dispose();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MedicalRecord record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('রেকর্ড মুছে ফেলবেন?'),
        content: Text('“${record.title}” এবং এর সংরক্ষিত ছবিগুলো মুছে যাবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('না'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('মুছে ফেলুন'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(medicalRecordsProvider.notifier).deleteRecord(record);
    }
  }

  void _showRecordDetails(BuildContext context, MedicalRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '${record.category} • ${DateFormat('dd MMM yyyy').format(record.date)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (record.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(record.notes!),
              ],
              if (record.filePaths.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'সংযুক্ত ছবি (${record.filePaths.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 260,
                  child: PageView.builder(
                    itemCount: record.filePaths.length,
                    itemBuilder: (context, index) {
                      final file = File(record.filePaths[index]);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: file.existsSync()
                            ? InteractiveViewer(
                                child: Image.file(file, fit: BoxFit.contain),
                              )
                            : const Center(child: Text('ছবিটি পাওয়া যায়নি')),
                      );
                    },
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                const Text('এই রেকর্ডে কোনো ছবি সংযুক্ত নেই।'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  final MedicalRecord record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final firstImage = record.filePaths.isEmpty
        ? null
        : File(record.filePaths.first);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: SizedBox(
          width: 54,
          height: 54,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: firstImage != null && firstImage.existsSync()
                ? Image.file(firstImage, fit: BoxFit.cover)
                : const ColoredBox(
                    color: Color(0xFFFCE4EC),
                    child: Icon(
                      Icons.description_outlined,
                      color: Colors.pinkAccent,
                    ),
                  ),
          ),
        ),
        title: Text(
          record.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${record.category} • ${DateFormat('dd MMM, yyyy').format(record.date)}'
          '${record.filePaths.isEmpty ? '' : ' • ${record.filePaths.length}টি ছবি'}',
          maxLines: 2,
        ),
        trailing: IconButton(
          tooltip: 'মুছে ফেলুন',
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _EmptyRecordsState extends StatelessWidget {
  const _EmptyRecordsState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'এখনো কোনো মেডিকেল রেকর্ড নেই',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'আল্ট্রাসাউন্ড, পরীক্ষা বা প্রেসক্রিপশনের ছবি এখানে রাখুন।',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('প্রথম রেকর্ড যোগ করুন'),
          ),
        ],
      ),
    ),
  );
}
