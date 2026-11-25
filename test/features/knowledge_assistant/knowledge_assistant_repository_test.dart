import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_care/features/knowledge_assistant/data/knowledge_assistant_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repository = KnowledgeAssistantRepository();

  test('finds Bangla FAQ answers offline', () async {
    final results = await repository.search('ফলিক অ্যাসিড কেন প্রয়োজন?');
    expect(results, isNotEmpty);
    expect(results.first.title, contains('ফলিক'));
    expect(results.first.sourceUrl, startsWith('https://'));
  });

  test('finds English FAQ keywords', () async {
    final results = await repository.search('medicine pregnancy safe');
    expect(results, isNotEmpty);
    expect(results.first.title, contains('ওষুধ'));
  });

  test('matches common Bangla medicine spelling variants', () async {
    final results = await repository.search('গর্ভাবস্থায় ঔষধ খাওয়া যাবে?');
    expect(results, isNotEmpty);
    expect(results.first.title, contains('ওষুধ'));
  });

  test('matches English reduced baby movement wording', () async {
    final results = await repository.search('baby not moving');
    expect(results, isNotEmpty);
    expect(results.first.title, contains('নড়াচড়া'));
  });

  test('accepts Bengali digits for pregnancy week search', () async {
    final results = await repository.search('১২ সপ্তাহে শিশুর বিকাশ');
    expect(results, hasLength(1));
    expect(results.single.week, 12);
  });

  test('opens a requested pregnancy week from local week data', () async {
    final results = await repository.search('week 12 baby development');
    expect(results, hasLength(1));
    expect(results.single.week, 12);
    expect(results.single.isWeekGuide, isTrue);
  });

  test('returns no fabricated answer for an unsupported question', () async {
    final results = await repository.search('আজ ঢাকার আবহাওয়া কেমন');
    expect(results, isEmpty);
  });
}
