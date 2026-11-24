import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/hive_service.dart';
import '../../../../shared/models/companion_note.dart';

class OurSpaceScreen extends StatefulWidget {
  const OurSpaceScreen({super.key});

  @override
  State<OurSpaceScreen> createState() => _OurSpaceScreenState();
}

class _OurSpaceScreenState extends State<OurSpaceScreen> {
  static const _categories = [
    'আমাদের কথা',
    'সহযোগিতা',
    'ছোট পরিকল্পনা',
    'ভালো লাগা',
  ];
  static const _authors = ['মা', 'সঙ্গী', 'আমরা দুজন'];
  final _searchController = TextEditingController();
  String _filter = 'সব';

  Box<CompanionNote> get _box =>
      HiveService.getBox<CompanionNote>(HiveService.companionNoteBoxName);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Space')),
      body: ValueListenableBuilder<Box<CompanionNote>>(
        valueListenable: _box.listenable(),
        builder: (context, box, _) {
          final query = _searchController.text.trim().toLowerCase();
          final notes =
              box.values.where((note) {
                final matchesQuery =
                    query.isEmpty ||
                    note.title.toLowerCase().contains(query) ||
                    note.content.toLowerCase().contains(query);
                final matchesCategory =
                    _filter == 'সব' || note.category == _filter;
                return matchesQuery && matchesCategory;
              }).toList()..sort((a, b) {
                if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
                return b.createdAt.compareTo(a.createdAt);
              });

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              _introCard(),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'আমাদের নোট খুঁজুন...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['সব', ..._categories]
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _filter == category,
                            onSelected: (_) =>
                                setState(() => _filter = category),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              if (notes.isEmpty)
                _emptyState(box.isNotEmpty)
              else
                ...notes.map((note) => _noteCard(note)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editNote(),
        icon: const Icon(Icons.add),
        label: const Text('নতুন নোট'),
      ),
    );
  }

  Widget _introCard() => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite_rounded),
              SizedBox(width: 8),
              Text('একসাথে এই যাত্রা'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ছোট কথা, যত্নের পরিকল্পনা আর একে অপরের জন্য ভালোবাসার বার্তা এখানে রাখুন।',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'এগুলো এই ডিভাইসেই সংরক্ষিত থাকবে; অন্য ফোনে নিজে থেকে সিঙ্ক হবে না।',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );

  Widget _emptyState(bool hasNotes) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 44),
    child: Column(
      children: [
        Icon(
          Icons.forum_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 10),
        Text(hasNotes ? 'এই খোঁজে কোনো নোট পাওয়া যায়নি' : 'এখনো কোনো নোট নেই'),
        const SizedBox(height: 4),
        const Text('একটি ছোট বার্তা বা পরিকল্পনা দিয়ে শুরু করুন।'),
      ],
    ),
  );

  Widget _noteCard(CompanionNote note) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              if (note.isPinned) const Icon(Icons.push_pin, size: 17),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _editNote(note: note);
                  if (value == 'pin') {
                    note.isPinned = !note.isPinned;
                    note.save();
                  }
                  if (value == 'delete') _deleteNote(note);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
                  PopupMenuItem(
                    value: 'pin',
                    child: Text(note.isPinned ? 'পিন সরান' : 'পিন করুন'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('মুছে ফেলুন'),
                  ),
                ],
              ),
            ],
          ),
          Text(note.content),
          const SizedBox(height: 10),
          Row(
            children: [
              Chip(
                label: Text(note.category),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 6),
              Text(note.author, style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Text(
                DateFormat('dd MMM yyyy').format(note.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _editNote({CompanionNote? note}) async {
    final title = TextEditingController(text: note?.title ?? '');
    final content = TextEditingController(text: note?.content ?? '');
    String author = note?.author ?? _authors.first;
    String category = note?.category ?? _categories.first;
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(note == null ? 'নতুন নোট' : 'নোট সম্পাদনা'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'শিরোনাম'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'শিরোনাম লিখুন'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: content,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'বিস্তারিত / বার্তা',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'কিছু লিখুন' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: author,
                      decoration: const InputDecoration(
                        labelText: 'কার পক্ষ থেকে',
                      ),
                      items: _authors
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => author = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'ধরন'),
                      items: _categories
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => category = v);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('বাতিল'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (note == null) {
                  await _box.add(
                    CompanionNote(
                      title: title.text.trim(),
                      content: content.text.trim(),
                      author: author,
                      category: category,
                      createdAt: DateTime.now(),
                    ),
                  );
                } else {
                  note
                    ..title = title.text.trim()
                    ..content = content.text.trim()
                    ..author = author
                    ..category = category;
                  await note.save();
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('সংরক্ষণ'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    content.dispose();
  }

  Future<void> _deleteNote(CompanionNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নোট মুছবেন?'),
        content: const Text('এই নোটটি স্থায়ীভাবে মুছে যাবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('মুছুন'),
          ),
        ],
      ),
    );
    if (confirmed == true) await note.delete();
  }
}
