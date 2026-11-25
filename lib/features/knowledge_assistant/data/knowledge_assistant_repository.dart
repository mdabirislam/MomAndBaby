import 'dart:convert';

import 'package:flutter/services.dart';

import '../../weekly_guide/domain/pregnancy_week.dart';
import '../domain/knowledge_answer.dart';

class KnowledgeAssistantRepository {
  List<Map<String, dynamic>>? _faqs;
  List<PregnancyWeek>? _weeks;

  Future<void> _load() async {
    if (_faqs != null && _weeks != null) return;
    final results = await Future.wait([
      rootBundle.loadString('assets/data/pregnancy_faq_bn.json'),
      rootBundle.loadString('assets/data/pregnancy_weeks.json'),
    ]);
    final faqJson = jsonDecode(results[0]) as List<dynamic>;
    final weekJson = jsonDecode(results[1]) as List<dynamic>;
    _faqs = faqJson.cast<Map<String, dynamic>>();
    _weeks = weekJson
        .map((item) => PregnancyWeek.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Searches only the bundled, curated content. No answer is generated.
  Future<List<KnowledgeAnswer>> search(String rawQuery) async {
    await _load();
    final query = _normalize(rawQuery);
    if (query.isEmpty) return const [];

    final requestedWeek = _extractWeek(query);
    if (requestedWeek != null && requestedWeek >= 1 && requestedWeek <= 40) {
      for (final week in _weeks!) {
        if (week.week == requestedWeek) return [_weekAnswer(week, query)];
      }
      return const [];
    }

    final queryTokens = _tokens(query);
    final expandedTokens = _expandedTokens(query);
    final ranked = <({int score, Map<String, dynamic> faq})>[];

    for (final faq in _faqs!) {
      final title = _normalize('${faq['title']} ${faq['question']}');
      final keywords = _normalize((faq['keywords'] as List).join(' '));
      final searchable = '$title $keywords';
      final searchableTokens = _tokens(searchable);
      var score = 0;

      for (final token in queryTokens) {
        if (searchableTokens.contains(token)) {
          score += token.length > 4 ? 5 : 3;
        } else if (token.length >= 4 &&
            searchableTokens.any(
              (item) => item.startsWith(token) || token.startsWith(item),
            )) {
          score += 1;
        }
      }

      for (final token in expandedTokens.difference(queryTokens)) {
        if (searchableTokens.contains(token)) score += 3;
      }

      if (query.length >= 4 && title.contains(query)) score += 12;
      if (query.length >= 4 && keywords.contains(query)) score += 8;
      if (score > 0) ranked.add((score: score, faq: faq));
    }

    ranked.sort((a, b) => b.score.compareTo(a.score));
    if (ranked.isEmpty || ranked.first.score < 3) return const [];

    return ranked.take(3).map((item) {
      final faq = item.faq;
      return KnowledgeAnswer(
        title: faq['title'] as String,
        answer: faq['answer'] as String,
        category: faq['category'] as String,
        sourceName: faq['source_name'] as String,
        sourceUrl: faq['source_url'] as String,
      );
    }).toList();
  }

  Set<String> _expandedTokens(String query) {
    final expanded = <String>{..._tokens(query)};
    for (final group in _synonymGroups) {
      if (group.any((term) => query.contains(term))) {
        for (final term in group) {
          expanded.addAll(_tokens(term));
        }
      }
    }
    return expanded;
  }

  KnowledgeAnswer _weekAnswer(PregnancyWeek week, String query) {
    var title = 'সপ্তাহ ${week.week}: শিশুর বিকাশ';
    var answer = week.babyDevelopment;
    const category = 'সপ্তাহভিত্তিক গাইড';

    if (_hasAny(query, ['মা', 'মায়ের', 'শরীর', 'পরিবর্তন', 'mother', 'body'])) {
      title = 'সপ্তাহ ${week.week}: মায়ের শরীরের পরিবর্তন';
      answer = week.motherBodyChanges;
    } else if (_hasAny(query, ['খাবার', 'পুষ্টি', 'খাব', 'diet', 'food'])) {
      title = 'সপ্তাহ ${week.week}: খাবার ও পুষ্টি';
      answer = '${week.dietToEat}\n\nযা এড়িয়ে চলবেন: ${week.dietToAvoid}';
    } else if (_hasAny(query, [
      'অস্বস্তি',
      'সমস্যা',
      'উপসর্গ',
      'discomfort',
      'symptom',
    ])) {
      title = 'সপ্তাহ ${week.week}: সাধারণ অস্বস্তি';
      answer = week.normalDiscomforts;
    } else if (_hasAny(query, [
      'সতর্ক',
      'বিপদ',
      'জরুরি',
      'danger',
      'warning',
    ])) {
      title = 'সপ্তাহ ${week.week}: জরুরি সতর্কতা';
      answer = week.dangerSigns;
    } else if (_hasAny(query, ['ওজন', 'আকার', 'size', 'weight', 'ফল'])) {
      title = 'সপ্তাহ ${week.week}: শিশুর আকার ও ওজন';
      answer =
          '${week.approximateBabySize}\n${week.approximateBabyWeight}\n${week.fruitComparison}';
    }

    return KnowledgeAnswer(
      title: title,
      answer: answer,
      category: category,
      sourceName: 'সপ্তাহভিত্তিক গাইড (প্রকল্পের স্থানীয় ডেটা)',
      sourceUrl: week.medicalReferences,
      week: week.week,
      isWeekGuide: true,
    );
  }

  int? _extractWeek(String query) {
    final normalizedDigits = query.replaceAllMapped(
      RegExp(r'[০-৯]'),
      (match) => '০১২৩৪৫৬৭৮৯'.indexOf(match.group(0)!).toString(),
    );
    final match = RegExp(
      r'(?:week|সপ্তাহ)\s*(\d{1,2})|(\d{1,2})\s*(?:week|সপ্তাহ(?:ে)?)',
    ).firstMatch(normalizedDigits);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? match.group(2)!);
  }

  bool _hasAny(String query, List<String> terms) =>
      terms.any((term) => query.contains(_normalize(term)));

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('ঔষধ', 'ওষুধ')
      .replaceAllMapped(
        RegExp(r'[০-৯]'),
        (match) => '০১২৩৪৫৬৭৮৯'.indexOf(match.group(0)!).toString(),
      )
      .replaceAll(RegExp(r'[^\u0980-\u09FFa-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Set<String> _tokens(String value) =>
      _normalize(value)
          .split(' ')
          .where((token) => token.length > 1 && !_stopWords.contains(token))
          .toSet();

  static const List<Set<String>> _synonymGroups = [
    {'ওষুধ', 'ঔষধ', 'মেডিসিন', 'medicine', 'medication', 'tablet', 'ট্যাবলেট'},
    {
      'বমি',
      'বমিভাব',
      'বমি বমি',
      'nausea',
      'vomit',
      'vomiting',
      'morning sickness',
    },
    {'রক্তপাত', 'রক্ত', 'স্পটিং', 'spotting', 'bleeding', 'bleed'},
    {
      'শিশুর নড়াচড়া',
      'বাচ্চা নড়ে',
      'কম নড়ে',
      'নড়ছে না',
      'movement',
      'reduced movement',
      'baby not moving',
      'kick less',
    },
    {
      'পানি ভাঙা',
      'পানির মতো তরল',
      'তরল বের হওয়া',
      'fluid leak',
      'water breaking',
      'watery discharge',
    },
    {'মাথাব্যথা', 'মাথা ব্যথা', 'headache', 'migraine'},
    {'খাবার', 'খাদ্য', 'ডায়েট', 'পুষ্টি', 'food', 'diet', 'nutrition'},
    {
      'চেকআপ',
      'ডাক্তার দেখানো',
      'গর্ভকালীন পরীক্ষা',
      'antenatal',
      'checkup',
      'appointment',
    },
    {'ঘুম', 'শোয়া', 'sleep', 'sleeping'},
    {'মন খারাপ', 'দুশ্চিন্তা', 'উদ্বেগ', 'anxiety', 'stress', 'depression'},
  ];

  static const _stopWords = {
    'আমি',
    'আমার',
    'কী',
    'কি',
    'কেন',
    'কখন',
    'কিভাবে',
    'হলে',
    'হয়',
    'হবে',
    'করব',
    'করবো',
    'পারি',
    'জন্য',
    'একটা',
    'একটু',
    'এবং',
    'the',
    'is',
    'are',
    'what',
    'how',
    'when',
    'can',
    'i',
    'my',
    'do',
    'in',
    'of',
    'to',
    'for',
    'হচ্ছে',
    'হচ্ছে',
    'হয়েছে',
    'হয়',
    'করে',
    'করতে',
    'আমাকে',
    'আমার',
  };
}
