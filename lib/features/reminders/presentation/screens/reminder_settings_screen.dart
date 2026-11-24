import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/notifications/notification_service.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  static const _waterKey = 'water_reminders_enabled';
  bool _waterEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _waterEnabled = prefs.getBool(_waterKey) ?? false;
      _loading = false;
    });
  }

  Future<void> _enableMedicineAndAppointmentReminders() async {
    final permitted = await NotificationService.instance.requestPermissions();
    if (permitted) {
      await NotificationService.instance.rescheduleAll();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            permitted
                ? 'ওষুধ ও অ্যাপয়েন্টমেন্ট রিমাইন্ডার চালু হয়েছে।'
                : 'Notification ও Exact Alarm permission চালু করুন।',
          ),
        ),
      );
    }
  }

  Future<void> _setWaterReminder(bool enabled) async {
    final service = NotificationService.instance;
    final permitted = enabled
        ? await service.requestNotificationPermission()
        : true;
    if (!permitted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'নোটিফিকেশন ও নির্দিষ্ট সময়ের অ্যালার্মের অনুমতি প্রয়োজন।',
            ),
          ),
        );
      }
      return;
    }
    await service.setWaterReminders(enabled);
    await service.rescheduleAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_waterKey, enabled);
    if (mounted) setState(() => _waterEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('রিমাইন্ডার সেটিংস')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.water_drop_outlined),
                    title: const Text('পানি পান করার স্মরণবার্তা'),
                    subtitle: const Text(
                      'সকাল ৯টা থেকে রাত ৯টা পর্যন্ত প্রতি ২ ঘণ্টায়। এটি কোনো দৈনিক পানির লক্ষ্য নির্ধারণ করে না।',
                    ),
                    value: _waterEnabled,
                    onChanged: _setWaterReminder,
                  ),
                ),
                const SizedBox(height: 12),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.medication_outlined),
                    title: Text('ওষুধের রিমাইন্ডার'),
                    subtitle: Text(
                      'ওষুধ যোগ বা সম্পাদনার সময় নির্ধারিত সময় অনুযায়ী স্বয়ংক্রিয়ভাবে তৈরি হয়।',
                    ),
                  ),
                ),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.event_outlined),
                    title: Text('অ্যাপয়েন্টমেন্ট রিমাইন্ডার'),
                    subtitle: Text(
                      'অ্যাপয়েন্টমেন্টের ১ দিন ও ২ ঘণ্টা আগে স্মরণ করাবে।',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _enableMedicineAndAppointmentReminders,
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text(
                      'ওষুধ ও অ্যাপয়েন্টমেন্ট রিমাইন্ডার অনুমতি দিন',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'নোট: Android-এর Battery Saver বা নির্মাতার ব্যাটারি ব্যবস্থাপনা কিছু নোটিফিকেশন দেরি করাতে পারে। ফোনের Settings থেকে Mom & Baby-এর Notification ও Alarm permission চালু রাখুন।',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
    );
  }
}
