import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/pregnancy_week.dart';
import '../providers/weekly_guide_providers.dart';

class WeeklyGuideScreen extends ConsumerStatefulWidget {
  final int week;

  const WeeklyGuideScreen({super.key, required this.week});

  @override
  ConsumerState<WeeklyGuideScreen> createState() => _WeeklyGuideScreenState();
}

class _WeeklyGuideScreenState extends ConsumerState<WeeklyGuideScreen> {
  static const _ink = Color(0xFF343044);
  static const _muted = Color(0xFF777486);
  static const _pink = Color(0xFFE982A5);
  static const _page = Color(0xFFFFF8FA);

  late int _selectedWeek;

  @override
  void initState() {
    super.initState();
    _selectedWeek = widget.week.clamp(1, 40).toInt();
  }

  void _changeWeek(int value) {
    if (value < 1 || value > 40) return;
    setState(() => _selectedWeek = value);
  }

  @override
  Widget build(BuildContext context) {
    final weekAsync = ref.watch(weeklyGuideProvider(_selectedWeek));

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        title: Text('সপ্তাহ $_selectedWeek'),
        backgroundColor: _page,
        surfaceTintColor: Colors.transparent,
      ),
      body: weekAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 42, color: _muted),
                const SizedBox(height: 12),
                const Text('তথ্য লোড করা যায়নি'),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(weeklyGuideProvider(_selectedWeek)),
                  child: const Text('আবার চেষ্টা করুন'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('এই সপ্তাহের তথ্য পাওয়া যায়নি।'));
          }
          return _buildContent(data);
        },
      ),
    );
  }

  Widget _buildContent(PregnancyWeek data) {
    final trimester = data.week <= 13
        ? 'প্রথম ত্রৈমাসিক'
        : data.week <= 27
        ? 'দ্বিতীয় ত্রৈমাসিক'
        : 'তৃতীয় ত্রৈমাসিক';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _weekSelector(trimester),
        const SizedBox(height: 14),
        _section(
          icon: Icons.child_care_rounded,
          title: 'শিশুর বিকাশ',
          content: data.babyDevelopment,
          tint: const Color(0xFFECE7FF),
        ),
        _section(
          icon: Icons.straighten_rounded,
          title: 'আকার ও ওজন',
          content:
              '${data.approximateBabySize}\n\n${data.approximateBabyWeight}\n\n${data.fruitComparison}',
          tint: const Color(0xFFE4F3EA),
        ),
        _section(
          icon: Icons.pregnant_woman_rounded,
          title: 'মায়ের শরীরের পরিবর্তন',
          content: data.motherBodyChanges,
          tint: const Color(0xFFFFE9D9),
        ),
        _section(
          icon: Icons.spa_outlined,
          title: 'সাধারণ অস্বস্তি',
          content: data.normalDiscomforts,
          tint: const Color(0xFFFFF1D9),
        ),
        _section(
          icon: Icons.restaurant_outlined,
          title: 'খাবার ও পুষ্টি',
          content: '${data.dietToEat}\n\nযা এড়িয়ে চলবেন:\n${data.dietToAvoid}',
          tint: const Color(0xFFE4F1F7),
        ),
        _section(
          icon: Icons.check_circle_outline_rounded,
          title: 'যত্নের পরামর্শ',
          content: data.lifestyleTips,
          tint: const Color(0xFFE4F3EA),
        ),
        _section(
          icon: Icons.warning_amber_rounded,
          title: 'জরুরি সতর্কতা',
          content: data.dangerSigns,
          tint: const Color(0xFFFFE6E6),
          isWarning: true,
        ),
        _referenceCard(data),
        const SizedBox(height: 12),
        const Text(
          'গুরুত্বপূর্ণ: এই তথ্য সাধারণ শিক্ষামূলক নির্দেশনা, ব্যক্তিগত চিকিৎসা পরামর্শ নয়। '
          'প্রতিটি গর্ভাবস্থা আলাদা। কোনো উদ্বেগ বা জরুরি লক্ষণ হলে চিকিৎসক/মাতৃসেবা কেন্দ্রে যোগাযোগ করুন।',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _weekSelector(String trimester) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8F0), Color(0xFFFFF1E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trimester,
            style: const TextStyle(color: _muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'সপ্তাহ $_selectedWeek',
                style: const TextStyle(
                  color: _ink,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '৪০-এর মধ্যে $_selectedWeek',
                  style: const TextStyle(color: _ink, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _selectedWeek / 40,
              minHeight: 8,
              backgroundColor: Colors.white,
              color: _pink,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _selectedWeek > 1
                    ? () => _changeWeek(_selectedWeek - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'আগের সপ্তাহ',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedWeek,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: List.generate(
                    40,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('সপ্তাহ ${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) _changeWeek(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _selectedWeek < 40
                    ? () => _changeWeek(_selectedWeek + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'পরের সপ্তাহ',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required String content,
    required Color tint,
    bool isWarning = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isWarning ? Border.all(color: const Color(0xFFF2B7B7)) : null,
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: _ink, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(color: _muted, fontSize: 14, height: 1.65),
          ),
        ],
      ),
    );
  }

  Widget _referenceCard(PregnancyWeek data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'তথ্যসূত্র',
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          _sourceLink(
            'ACOG — How Your Fetus Grows During Pregnancy',
            'https://www.acog.org/womens-health/faqs/how-your-fetus-grows-during-pregnancy',
          ),
          _sourceLink(
            'NHS — Week-by-week pregnancy guide',
            'https://www.nhs.uk/best-start-in-life/pregnancy/week-by-week-guide-to-pregnancy/',
          ),
          _sourceLink(
            'NHS Inform — Baby development week to week',
            'https://www.nhsinform.scot/ready-steady-baby/pregnancy/your-baby-s-development/how-your-baby-develops-week-to-week/',
          ),
          const SizedBox(height: 8),
          Text(
            'তথ্য হালনাগাদ: ${data.lastReviewed} · চিকিৎসক দ্বারা যাচাই বাকি',
            style: const TextStyle(color: _muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _sourceLink(String label, String url) {
    return TextButton(
      onPressed: () async {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 4),
      ),
      child: Text(label, textAlign: TextAlign.left),
    );
  }
}
