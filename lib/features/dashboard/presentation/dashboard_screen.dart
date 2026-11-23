import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/pregnancy_calculator.dart';
import '../../../shared/providers/user_provider.dart';
import '../../daily_care/presentation/screens/kick_counter_screen.dart';
import '../../daily_care/presentation/widgets/water_tracker_widget.dart';
import '../../diary/presentation/screens/diary_list_screen.dart';
import '../../emergency/presentation/emergency_screen.dart';
import '../../medicines/presentation/screens/medicine_list_screen.dart';
import '../../weekly_guide/presentation/weekly_guide_screen.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _ink = Color(0xFF343044);
  static const _muted = Color(0xFF777486);
  static const _pink = Color(0xFFE982A5);
  static const _page = Color(0xFFFFF8FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final progress = ref.watch(pregnancyProgressProvider);
    final rawWeek = progress['week'] as int? ?? 1;
    final week = rawWeek.clamp(1, 40).toInt();
    final day = (progress['day'] as int? ?? 0).clamp(0, 6).toInt();
    final percentage = ((progress['progress'] as num?)?.toDouble() ?? 0)
        .clamp(0.0, 1.0)
        .toDouble();
    final remainingDays = (progress['remainingDays'] as int? ?? 0)
        .clamp(0, 280)
        .toInt();
    final dueDate = profile == null
        ? null
        : (profile.eddOverride ??
              PregnancyCalculator.calculateEDD(profile.lmp));

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.favorite_rounded, color: _pink, size: 23),
            SizedBox(width: 9),
            Text('মা ও শিশু', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'জরুরি যোগাযোগ',
            onPressed: () => _open(context, const EmergencyScreen()),
            icon: const Icon(Icons.emergency_outlined, color: _ink),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Text(
              'হ্যালো, ${profile?.name.trim().isNotEmpty == true ? profile!.name : 'মা'} 🌷',
              style: const TextStyle(
                color: _ink,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              profile?.welcomeMessage?.trim().isNotEmpty == true
                  ? profile!.welcomeMessage!
                  : 'আজকের দিনটি নিজের যত্নে কাটুক।',
              style: const TextStyle(color: _muted, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _PregnancyHero(
              week: week,
              day: day,
              progress: percentage,
              remainingDays: remainingDays,
              dueDate: dueDate,
              onTap: () => _open(context, WeeklyGuideScreen(week: week)),
            ),
            const SizedBox(height: 24),
            const _SectionHeading(
              title: 'আজকের যত্ন',
              subtitle: 'ছোট ছোট অভ্যাসে নিজের যত্ন নিন',
            ),
            const SizedBox(height: 12),
            _WaterCard(),
            const SizedBox(height: 22),
            const _SectionHeading(
              title: 'দ্রুত ব্যবহার',
              subtitle: 'প্রয়োজনীয় ফিচারগুলো এক জায়গায়',
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              childAspectRatio: 1.65,
              children: [
                _ActionTile(
                  title: 'ওষুধের তালিকা',
                  subtitle: 'নিজের নোট ও তালিকা',
                  icon: Icons.medication_outlined,
                  color: const Color(0xFFFFE9D9),
                  onTap: () => _open(context, const MedicineListScreen()),
                ),
                _ActionTile(
                  title: 'শিশুর নড়াচড়া',
                  subtitle: 'কিক কাউন্টার',
                  icon: Icons.child_care_rounded,
                  color: const Color(0xFFECE7FF),
                  onTap: () => _open(context, const KickCounterScreen()),
                ),
                _ActionTile(
                  title: 'স্মৃতির ডায়েরি',
                  subtitle: 'মুহূর্ত লিখে রাখুন',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFFE1F3E9),
                  onTap: () => _open(context, const DiaryListScreen()),
                ),
                _ActionTile(
                  title: 'জরুরি সহায়তা',
                  subtitle: 'যোগাযোগের তথ্য',
                  icon: Icons.health_and_safety_outlined,
                  color: const Color(0xFFFFE5E8),
                  onTap: () => _open(context, const EmergencyScreen()),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _WeeklyGuideCard(
              week: week,
              onTap: () => _open(context, WeeklyGuideScreen(week: week)),
            ),
            const SizedBox(height: 14),
            const _Disclaimer(),
          ],
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _PregnancyHero extends StatelessWidget {
  const _PregnancyHero({
    required this.week,
    required this.day,
    required this.progress,
    required this.remainingDays,
    required this.dueDate,
    required this.onTap,
  });

  final int week;
  final int day;
  final double progress;
  final int remainingDays;
  final DateTime? dueDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateText = dueDate == null
        ? 'তারিখ পাওয়া যায়নি'
        : '${dueDate!.day.toString().padLeft(2, '0')}/${dueDate!.month.toString().padLeft(2, '0')}/${dueDate!.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF6B6C9), Color(0xFFECA4BE), Color(0xFFDDA9D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE69DBB).withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'তোমার মাতৃত্বের যাত্রা',
                style: TextStyle(
                  color: Color(0xFF633E58),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${(progress * 100).round()}% সম্পন্ন',
                  style: const TextStyle(
                    color: Color(0xFF633E58),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$week',
                style: const TextStyle(
                  color: Color(0xFF51364D),
                  fontSize: 54,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 5),
                child: Text(
                  'সপ্তাহ',
                  style: TextStyle(
                    color: Color(0xFF633E58),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.child_friendly_rounded,
                size: 62,
                color: Color(0x8851364D),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'এই সপ্তাহের ${day + 1}তম দিন',
            style: const TextStyle(
              color: Color(0xFF633E58),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.45),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF87516F)),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 17,
                color: Color(0xFF633E58),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'সম্ভাব্য প্রসবের তারিখ: $dateText',
                  style: const TextStyle(
                    color: Color(0xFF633E58),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$remainingDays দিন বাকি',
                style: const TextStyle(
                  color: Color(0xFF633E58),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF56384F),
                backgroundColor: Colors.white.withValues(alpha: 0.55),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.auto_stories_rounded, size: 17),
              label: const Text(
                'এই সপ্তাহের গাইড',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECE8EF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBubble(
                icon: Icons.water_drop_rounded,
                color: Color(0xFFDFF1FF),
                iconColor: Color(0xFF4A9BCB),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'পানি পান',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF343044),
                  ),
                ),
              ),
              Text(
                'ট্র্যাকার',
                style: TextStyle(fontSize: 12, color: Color(0xFF777486)),
              ),
            ],
          ),
          SizedBox(height: 13),
          WaterTrackerWidget(),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF343044),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF777486), fontSize: 12),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECE8EF)),
          ),
          child: Row(
            children: [
              _IconBubble(
                icon: icon,
                color: color,
                iconColor: const Color(0xFF51475C),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF343044),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF858191),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.color,
    required this.iconColor,
  });
  final IconData icon;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

class _WeeklyGuideCard extends StatelessWidget {
  const _WeeklyGuideCard({required this.week, required this.onTap});
  final int week;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0ECFA),
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const _IconBubble(
                icon: Icons.auto_stories_rounded,
                color: Color(0xFFE0D8F5),
                iconColor: Color(0xFF7662A8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'সপ্তাহ $week সম্পর্কে জানুন',
                      style: const TextStyle(
                        color: Color(0xFF453B60),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'শিশুর বিকাশ ও মায়ের যত্নের গাইড',
                      style: TextStyle(color: Color(0xFF777086), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF7662A8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF96919F)),
        SizedBox(width: 7),
        Expanded(
          child: Text(
            'এই অ্যাপটি তথ্য ও ব্যক্তিগত ট্র্যাকিংয়ের সহায়ক; চিকিৎসকের পরামর্শের বিকল্প নয়।',
            style: TextStyle(
              color: Color(0xFF96919F),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
