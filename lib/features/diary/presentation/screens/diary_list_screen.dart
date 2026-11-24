import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/diary_entry.dart';
import '../../data/diary_image_service.dart';
import '../../providers/diary_providers.dart';

class DiaryListScreen extends ConsumerStatefulWidget {
  const DiaryListScreen({super.key});

  @override
  ConsumerState<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends ConsumerState<DiaryListScreen> {
  final _searchController = TextEditingController();
  String _moodFilter = 'সব';

  static const _moods = [
    'খুশি',
    'শান্ত',
    'উচ্ছ্বসিত',
    'চিন্তিত',
    'ক্লান্ত',
    'মন খারাপ',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(diaryEntriesProvider);
    final query = _searchController.text.trim().toLowerCase();
    final filtered = entries.where((entry) {
      final matchesText =
          query.isEmpty ||
          entry.content.toLowerCase().contains(query) ||
          (entry.mood ?? '').toLowerCase().contains(query);
      final matchesMood = _moodFilter == 'সব' || entry.mood == _moodFilter;
      return matchesText && matchesMood;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমাদের স্মৃতির ডায়েরি'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ডায়েরির লেখা খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: ['সব', ..._moods].map((mood) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 7,
                  ),
                  child: ChoiceChip(
                    label: Text(mood),
                    selected: _moodFilter == mood,
                    onSelected: (_) => setState(() => _moodFilter = mood),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyDiary(hasEntries: entries.isNotEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _DiaryCard(
                      entry: filtered[index],
                      onEdit: () => _openEditor(entry: filtered[index]),
                      onDelete: () => _confirmDelete(filtered[index]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.edit_note),
        label: const Text('স্মৃতি লিখুন'),
      ),
    );
  }

  Future<void> _openEditor({DiaryEntry? entry}) async {
    final contentController = TextEditingController(text: entry?.content ?? '');
    final weekController = TextEditingController(
      text: entry?.pregnancyWeek?.toString() ?? '',
    );
    DateTime selectedDate = entry?.date ?? DateTime.now();
    String? selectedMood = entry?.mood;
    List<String> imagePaths = [...?entry?.imagePaths];
    bool saving = false;
    bool didSave = false;
    final originalPaths = [...?entry?.imagePaths];

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(entry == null ? 'নতুন স্মৃতি' : 'স্মৃতি সম্পাদনা'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null)
                        setDialogState(() => selectedDate = date);
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedMood,
                    decoration: const InputDecoration(
                      labelText: 'আজকের অনুভূতি',
                    ),
                    items: _moods
                        .map(
                          (mood) =>
                              DropdownMenuItem(value: mood, child: Text(mood)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedMood = value),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: weekController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'গর্ভাবস্থার সপ্তাহ (ঐচ্ছিক)',
                      hintText: 'যেমন: ১২',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contentController,
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 3000,
                    decoration: const InputDecoration(
                      labelText: 'আজকের স্মৃতি',
                      hintText: 'আজ কী অনুভব করলেন, কী ঘটল...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final result =
                              await DiaryImageService.pickAndSaveImages(
                                existingPaths: imagePaths,
                                fromCamera: false,
                              );
                          setDialogState(() => imagePaths = result);
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('গ্যালারি'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final result =
                              await DiaryImageService.pickAndSaveImages(
                                existingPaths: imagePaths,
                                fromCamera: true,
                              );
                          setDialogState(() => imagePaths = result);
                        },
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('ক্যামেরা'),
                      ),
                    ],
                  ),
                  if (imagePaths.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: imagePaths.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(imagePaths[index]),
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 76,
                                  height: 76,
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: InkWell(
                                onTap: () => setDialogState(
                                  () => imagePaths.removeAt(index),
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('বাতিল'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final content = contentController.text.trim();
                      final weekText = weekController.text.trim();
                      final week = int.tryParse(weekText);
                      if (content.isEmpty ||
                          (weekText.isNotEmpty &&
                              (week == null || week < 1 || week > 42))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'লেখা দিন এবং সপ্তাহ ১–৪২-এর মধ্যে রাখুন।',
                            ),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => saving = true);
                      final notifier = ref.read(diaryEntriesProvider.notifier);
                      if (entry == null) {
                        await notifier.addEntry(
                          content,
                          mood: selectedMood,
                          date: selectedDate,
                          imagePaths: imagePaths,
                          pregnancyWeek: week,
                        );
                      } else {
                        final oldPaths = [...?entry.imagePaths];
                        entry
                          ..content = content
                          ..date = selectedDate
                          ..mood = selectedMood
                          ..pregnancyWeek = week
                          ..imagePaths = imagePaths;
                        await notifier.updateEntry(entry);
                        await DiaryImageService.deleteUnusedImages(
                          oldPaths,
                          imagePaths,
                        );
                      }
                      didSave = true;
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
              child: Text(entry == null ? 'সংরক্ষণ' : 'আপডেট'),
            ),
          ],
        ),
      ),
    );
    if (!didSave) {
      await DiaryImageService.deleteUnusedImages(imagePaths, originalPaths);
    }
    contentController.dispose();
    weekController.dispose();
  }

  Future<void> _confirmDelete(DiaryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('স্মৃতিটি মুছে ফেলবেন?'),
        content: const Text(
          'এই ডায়েরি এন্ট্রি ও এর সংযুক্ত ছবিগুলো মুছে যাবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('মুছে ফেলুন'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final paths = [...?entry.imagePaths];
      await ref.read(diaryEntriesProvider.notifier).deleteEntry(entry);
      await DiaryImageService.deleteUnusedImages(paths, const []);
    }
  }
}

class _DiaryCard extends StatelessWidget {
  const _DiaryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final DiaryEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final images = entry.imagePaths ?? const <String>[];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.pink, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('dd MMMM, yyyy').format(entry.date),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      value == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
                    PopupMenuItem(value: 'delete', child: Text('মুছে ফেলুন')),
                  ],
                ),
              ],
            ),
            if (entry.pregnancyWeek != null || entry.mood != null) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  if (entry.pregnancyWeek != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.child_friendly, size: 16),
                      label: Text('${entry.pregnancyWeek} সপ্তাহ'),
                    ),
                  if (entry.mood != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.mood, size: 16),
                      label: Text(entry.mood!),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              entry.content,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),
            if (images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 104,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) => Dialog(
                        child: InteractiveViewer(
                          child: Image.file(
                            File(images[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(images[index]),
                        width: 120,
                        height: 104,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          width: 120,
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyDiary extends StatelessWidget {
  const _EmptyDiary({required this.hasEntries});
  final bool hasEntries;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              hasEntries
                  ? 'কোনো মিল পাওয়া যায়নি'
                  : 'এখনো কোনো স্মৃতি লেখা হয়নি',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'ছোট ছোট মুহূর্তগুলো লিখে রাখুন—পরে এগুলোই হয়ে উঠবে অমূল্য স্মৃতি।',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
