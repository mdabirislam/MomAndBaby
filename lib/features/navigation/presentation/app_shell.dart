import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/user_provider.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../daily_care/presentation/screens/kick_counter_screen.dart';
import '../../daily_care/presentation/widgets/water_tracker_widget.dart';
import '../../diary/presentation/screens/diary_list_screen.dart';
import '../../emergency/presentation/emergency_screen.dart';
import '../../medicines/presentation/screens/medicine_list_screen.dart';
import '../../weekly_guide/presentation/weekly_guide_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    DashboardScreen(),
    _BabyTab(),
    _CareTab(),
    _PlannerTab(),
    _MoreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.child_friendly_outlined),
            selectedIcon: Icon(Icons.child_friendly),
            label: 'শিশু',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'যত্ন',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'পরিকল্পনা',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'আরও',
          ),
        ],
      ),
    );
  }
}

class _BabyTab extends ConsumerWidget {
  const _BabyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(pregnancyProgressProvider);
    final week = (progress['week'] ?? 1).clamp(1, 40).toInt();
    return Scaffold(
      appBar: AppBar(title: const Text('আমার শিশু')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            icon: Icons.child_care,
            title: 'এই সপ্তাহে শিশুর বৃদ্ধি',
            subtitle: 'বর্তমান গর্ভকাল: $week সপ্তাহ',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WeeklyGuideScreen(week: week)),
            ),
          ),
          const SizedBox(height: 12),
          const _InfoPanel(
            title: 'সপ্তাহভিত্তিক গাইড',
            message: 'শিশুর বৃদ্ধি, মায়ের শারীরিক পরিবর্তন, পুষ্টি ও সতর্কতার তথ্য ধাপে ধাপে এখানে যুক্ত করা হবে। বর্তমানে প্রকল্পে থাকা সপ্তাহগুলোর তথ্যই দেখানো হচ্ছে.',
          ),
        ],
      ),
    );
  }
}

class _CareTab extends StatelessWidget {
  const _CareTab();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('মায়ের যত্ন')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: WaterTrackerWidget(),
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: Icons.medication_outlined,
          title: 'ওষুধের তালিকা',
          subtitle: 'ওষুধ ও গ্রহণের লগ',
          onTap: () => _open(context, const MedicineListScreen()),
        ),
        _SectionCard(
          icon: Icons.child_friendly,
          title: 'কিক কাউন্টার',
          subtitle: 'শিশুর নড়াচড়ার সেশন নথিভুক্ত করুন',
          onTap: () => _open(context, const KickCounterScreen()),
        ),
        const SizedBox(height: 8),
        const _InfoPanel(
          title: 'স্বাস্থ্য সংক্রান্ত সতর্কতা',
          message: 'এই ট্র্যাকারগুলো ব্যক্তিগত নথি রাখার জন্য; এগুলো চিকিৎসকের পরামর্শ বা জরুরি মূল্যায়নের বিকল্প নয়।',
        ),
      ],
    ),
  );
}

class _PlannerTab extends StatelessWidget {
  const _PlannerTab();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('পরিকল্পনা')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionCard(
          icon: Icons.event_available,
          title: 'ডাক্তারের অ্যাপয়েন্টমেন্ট',
          subtitle: 'অ্যাপয়েন্টমেন্ট ব্যবস্থাপনা পরবর্তী ধাপে তৈরি হবে',
        ),
        _SectionCard(
          icon: Icons.folder_open,
          title: 'মেডিকেল রেকর্ড',
          subtitle: 'রিপোর্ট ও প্রেসক্রিপশন সংরক্ষণ',
        ),
        _SectionCard(
          icon: Icons.notifications_active_outlined,
          title: 'রিমাইন্ডার',
          subtitle: 'নোটিফিকেশন ব্যবস্থা পরবর্তী ধাপে যুক্ত হবে',
        ),
        SizedBox(height: 8),
        _InfoPanel(
          title: 'নির্মাণাধীন',
          message: 'এই বিভাগের Navigation ও প্রাথমিক কাঠামো তৈরি হয়েছে। Appointment, medical records ও reminder-এর কার্যকর ব্যবস্থা পরবর্তী Feature milestone-এ যুক্ত হবে।',
        ),
      ],
    ),
  );
}

class _MoreTab extends ConsumerWidget {
  const _MoreTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('আরও')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(profile?.name ?? 'ব্যবহারকারী'),
              subtitle: const Text('Mom & Baby প্রোফাইল'),
            ),
          ),
          _MenuTile(
            icon: Icons.menu_book_outlined,
            title: 'মেমোরি ডায়েরি',
            onTap: () => _open(context, const DiaryListScreen()),
          ),
          _MenuTile(
            icon: Icons.emergency_outlined,
            title: 'জরুরি যোগাযোগ',
            onTap: () => _open(context, const EmergencyScreen()),
          ),
          const _MenuTile(
            icon: Icons.people_outline,
            title: 'Our Space',
            subtitle: 'পরবর্তী ধাপে যুক্ত হবে',
          ),
          const _MenuTile(
            icon: Icons.settings_outlined,
            title: 'সেটিংস',
            subtitle: 'পরবর্তী ধাপে যুক্ত হবে',
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.message});
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer
          .withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(message),
      ],
    ),
  );
}

void _open(BuildContext context, Widget page) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
