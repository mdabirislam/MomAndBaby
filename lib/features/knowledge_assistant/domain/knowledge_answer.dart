class KnowledgeAnswer {
  const KnowledgeAnswer({
    required this.title,
    required this.answer,
    required this.category,
    required this.sourceName,
    required this.sourceUrl,
    this.week,
    this.isWeekGuide = false,
  });

  final String title;
  final String answer;
  final String category;
  final String sourceName;
  final String sourceUrl;
  final int? week;
  final bool isWeekGuide;
}
