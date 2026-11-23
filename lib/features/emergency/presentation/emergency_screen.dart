import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/providers/user_provider.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('জরুরি যোগাযোগ'),
        centerTitle: true,
        backgroundColor: Colors.red[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.emergency_share, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              'যেকোনো জরুরি প্রয়োজনে আপনার চিকিৎসক বা পরিবারকে কল করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildEmergencyCard(
              context,
              'চিকিৎসক',
              profile?.doctorName ?? 'সেভ করা নেই',
              profile?.doctorPhone,
              Icons.medical_services,
              Colors.blue[100]!,
            ),
            const SizedBox(height: 20),
            _buildEmergencyCard(
              context,
              'জরুরি কন্টাক্ট',
              profile?.emergencyContactName ?? 'সেভ করা নেই',
              profile?.emergencyContactPhone,
              Icons.family_restroom,
              Colors.green[100]!,
            ),
            const Spacer(),
            Card(
              color: Colors.red[50],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'তীব্র রক্তপাত, প্রচণ্ড পেট ব্যথা বা পানি ভাঙলে দেরি না করে হাসপাতালে যান।',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(
    BuildContext context,
    String title,
    String name,
    String? phone,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(name, style: const TextStyle(fontSize: 16)),
        trailing: phone != null
            ? IconButton(
                icon: const Icon(Icons.call, color: Colors.green, size: 30),
                onPressed: () => _makeCall(phone),
              )
            : null,
      ),
    );
  }
}
