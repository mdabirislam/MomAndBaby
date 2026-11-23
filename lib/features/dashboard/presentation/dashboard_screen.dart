import '../../daily_care/presentation/screens/kick_counter_screen.dart';
import '../../medicines/presentation/screens/medicine_list_screen.dart';
import '../../diary/presentation/screens/diary_list_screen.dart';
import '../../emergency/presentation/emergency_screen.dart';
import '../../daily_care/presentation/widgets/water_tracker_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/user_provider.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_card.dart';
import '../../weekly_guide/presentation/weekly_guide_screen.dart';
import '../../weekly_guide/presentation/weekly_guide_selector.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final progress = ref.watch(pregnancyProgressProvider);
    final currentWeek = progress['week'] ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(title: const Text('মা ও শিশু'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'স্বাগতম, ${profile?.name ?? 'মা'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (profile?.welcomeMessage != null)
                    Text(profile!.welcomeMessage!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                ],
              ),
            ),
            if (progress.isNotEmpty)
              DashboardCard(
                title: 'গর্ভাবস্থার অগ্রগতি',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('সপ্তাহ ${progress['week']}, দিন ${progress['day']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${(progress['progress'] * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress['progress'],
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${progress['remainingDays']} দিন বাকি', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('সাপ্তাহিক গাইড', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            WeeklyGuideSelector(currentWeek: currentWeek),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'পানি পান ট্র্যাকার',
              child: const WaterTrackerWidget(),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              childAspectRatio: 1.5,
              children: [
                _buildQuickAction(context, 'ওষুধ', Icons.medication, Colors.orange[100]!, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicineListScreen()));
                }),
                _buildQuickAction(context, 'কিক কাউন্টার', Icons.child_care, Colors.purple[100]!, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const KickCounterScreen()));
                }),
                _buildQuickAction(context, 'ডায়েরি', Icons.book, Colors.green[100]!, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryListScreen()));
                }),
                _buildQuickAction(context, 'জরুরি যোগাযোগ', Icons.emergency, Colors.red[100]!, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()));
                }),
              ],
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'সাপ্তাহিক গাইড দেখুন',
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(child: Text('আপনার শিশুর এই সপ্তাহের বৃদ্ধি সম্পর্কে জানুন।')),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WeeklyGuideScreen(week: currentWeek)),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}


