import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/diary_providers.dart';

class DiaryListScreen extends ConsumerWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(diaryEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('গর্ভাবস্থার ডায়েরি'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMMM, yyyy - hh:mm a').format(entry.date),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(entry.content, style: const TextStyle(fontSize: 16)),
                  if (entry.mood != null) ...[
                    const SizedBox(height: 8),
                    Text('অনুভূতি: ${entry.mood}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context, ref),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context, WidgetRef ref) {
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নতুন ডায়েরি লিখুন'),
        content: TextField(
          controller: contentController,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'আপনার অনুভূতি এখানে লিখুন...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () {
              if (contentController.text.isNotEmpty) {
                ref.read(diaryEntriesProvider.notifier).addEntry(contentController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
  }
}
