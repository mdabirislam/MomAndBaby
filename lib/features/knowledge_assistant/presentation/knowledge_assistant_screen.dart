import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/knowledge_assistant_repository.dart';
import '../domain/knowledge_answer.dart';

final knowledgeAssistantRepositoryProvider = Provider(
  (ref) => KnowledgeAssistantRepository(),
);

final knowledgeSearchProvider =
    FutureProvider.family<List<KnowledgeAnswer>, String>(
      (ref, query) =>
          ref.watch(knowledgeAssistantRepositoryProvider).search(query),
    );

class KnowledgeAssistantScreen extends ConsumerStatefulWidget {
  const KnowledgeAssistantScreen({super.key});

  @override
  ConsumerState<KnowledgeAssistantScreen> createState() =>
      _KnowledgeAssistantScreenState();
}

class _KnowledgeAssistantScreenState
    extends ConsumerState<KnowledgeAssistantScreen> {
  static const _recentKey = 'knowledge_assistant_recent_v2';
  static const _unansweredKey = 'knowledge_assistant_unanswered_v2';

  final _controller = TextEditingController();
  String _query = '';
  List<String> _recentQueries = [];
  List<String> _unansweredQueries = [];

  static const _suggestions = [
    'ফলিক অ্যাসিড কেন প্রয়োজন?',
    'গর্ভাবস্থায় কোন খাবার এড়িয়ে চলব?',
    'শিশুর নড়াচড়া কমে গেলে কী করব?',
    'ওষুধ খাওয়া কি নিরাপদ?',
    '১২ সপ্তাহে শিশুর বিকাশ',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedQuestions();
  }

  Future<void> _loadSavedQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _recentQueries = prefs.getStringList(_recentKey) ?? [];
      _unansweredQueries = prefs.getStringList(_unansweredKey) ?? [];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search([String? value]) async {
    final query = (value ?? _controller.text).trim();
    if (query.isEmpty) return;
    _controller.text = query;

    final prefs = await SharedPreferences.getInstance();
    final updated = [query, ..._recentQueries.where((item) => item != query)];
    final limited = updated.take(8).toList();
    await prefs.setStringList(_recentKey, limited);
    if (!mounted) return;
    setState(() {
      _recentQueries = limited;
      _query = query;
    });
  }

  Future<void> _saveUnansweredQuestion() async {
    if (_query.isEmpty || _unansweredQueries.contains(_query)) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [_query, ..._unansweredQueries].take(30).toList();
    await prefs.setStringList(_unansweredKey, updated);
    if (!mounted) return;
    setState(() => _unansweredQueries = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('প্রশ্নটি এই ডিভাইসে সংরক্ষণ করা হয়েছে।')),
    );
  }

  Future<void> _clearSavedQuestions(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    if (!mounted) return;
    setState(() {
      if (key == _recentKey) _recentQueries = [];
      if (key == _unansweredKey) _unansweredQueries = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _query.isEmpty
        ? null
        : ref.watch(knowledgeSearchProvider(_query));
    return Scaffold(
      appBar: AppBar(title: const Text('জ্ঞান সহায়ক')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer
                  .withValues(alpha: .55),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.offline_bolt_outlined),
                    SizedBox(width: 8),
                    Text(
                      'অফলাইন Pregnancy Assistant',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'বাংলা বা ইংরেজিতে প্রশ্ন লিখুন। পরিচিত শব্দের বিকল্প ধরেও তথ্য খোঁজা হয়। উত্তরগুলো অ্যাপের স্থানীয় তথ্য থেকে আসে—ইন্টারনেট বা Paid API লাগে না।',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: _search,
            decoration: InputDecoration(
              hintText: 'যেমন: গর্ভাবস্থায় মাথাব্যথা হলে কী করব?',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'খুঁজুন',
                onPressed: _search,
                icon: const Icon(Icons.send_rounded),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'প্রশ্নের নমুনা',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map(
                  (item) => ActionChip(
                    label: Text(item),
                    onPressed: () => _search(item),
                  ),
                )
                .toList(),
          ),
          if (_recentQueries.isNotEmpty) ...[
            const SizedBox(height: 18),
            _savedQuestionHeader('সাম্প্রতিক প্রশ্ন', _recentKey),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentQueries
                  .map(
                    (item) => ActionChip(
                      avatar: const Icon(Icons.history, size: 16),
                      label: Text(
                        item,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () => _search(item),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (_unansweredQueries.isNotEmpty) ...[
            const SizedBox(height: 16),
            _savedQuestionHeader(
              'উত্তর না পাওয়া সংরক্ষিত প্রশ্ন',
              _unansweredKey,
            ),
            const SizedBox(height: 6),
            ..._unansweredQueries.map(
              (item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline),
                title: Text(item),
                onTap: () => _search(item),
              ),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 22),
            const Text(
              'খোঁজের ফলাফল',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            result.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) =>
                  _message('তথ্য লোড করা যায়নি। আবার চেষ্টা করুন।'),
              data: (answers) => answers.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _message(
                          'এই প্রশ্নের সঙ্গে মেলে এমন নির্ভরযোগ্য তথ্য পাওয়া যায়নি। অন্যভাবে প্রশ্ন করুন অথবা চিকিৎসকের সঙ্গে কথা বলুন।',
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _unansweredQueries.contains(_query)
                              ? null
                              : _saveUnansweredQuestion,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text(
                            _unansweredQueries.contains(_query)
                                ? 'প্রশ্নটি সংরক্ষিত'
                                : 'প্রশ্নটি পরে পর্যালোচনার জন্য সংরক্ষণ করুন',
                          ),
                        ),
                      ],
                    )
                  : Column(children: answers.map(_answerCard).toList()),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7A49B)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emergency_outlined, color: Color(0xFF9D3026)),
                    SizedBox(width: 8),
                    Text(
                      'জরুরি সতর্কতা',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9D3026),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                Text(
                  'বেশি রক্তপাত, তীব্র/স্থায়ী পেটব্যথা, অজ্ঞান হওয়া বা খিঁচুনি, বুকব্যথা/শ্বাসকষ্ট, তীব্র মাথাব্যথা বা দৃষ্টির পরিবর্তন, পানি বের হওয়া, অথবা শিশুর স্বাভাবিক নড়াচড়া কমে/বন্ধ হলে এখনই চিকিৎসা সহায়তা নিন। অ্যাপের উত্তরের জন্য অপেক্ষা করবেন না।',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'সীমাবদ্ধতা: এটি AI চিকিৎসক নয়। তথ্য সাধারণ শিক্ষামূলক; রোগ নির্ণয়, ব্যক্তিগত চিকিৎসা সিদ্ধান্ত বা ওষুধের প্রেসক্রিপশন দেয় না। ডেটা চিকিৎসক দ্বারা যাচাই না হওয়া পর্যন্ত এটিকে একমাত্র চিকিৎসা-উৎস হিসেবে ব্যবহার করবেন না।',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _savedQuestionHeader(String title, String key) => Row(
    children: [
      Expanded(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      TextButton(
        onPressed: () => _clearSavedQuestions(key),
        child: const Text('মুছুন'),
      ),
    ],
  );

  Widget _answerCard(KnowledgeAnswer answer) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer.category,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            answer.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          SelectableText(answer.answer, style: const TextStyle(height: 1.55)),
          const SizedBox(height: 10),
          Text(
            'তথ্যসূত্র: ${answer.sourceName}',
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          if (!answer.isWeekGuide && answer.sourceUrl.startsWith('https://'))
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(answer.sourceUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('মূল উৎস দেখুন'),
              ),
            )
          else if (answer.isWeekGuide)
            const Text(
              'সপ্তাহভিত্তিক তথ্যের উৎস-লিংক JSON-এ সংরক্ষিত; clinician review pending.',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
        ],
      ),
    ),
  );

  Widget _message(String text) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(text),
  );
}
