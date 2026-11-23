import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/daily_care_providers.dart';
import '../../../../shared/models/daily_care.dart';

class KickCounterScreen extends ConsumerStatefulWidget {
  const KickCounterScreen({super.key});

  @override
  ConsumerState<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends ConsumerState<KickCounterScreen> {
  int _count = 0;
  bool _isSessionActive = false;
  DateTime? _startTime;
  Timer? _timer;
  Duration _duration = Duration.zero;

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _startTime = DateTime.now();
      _count = 0;
      _duration = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = DateTime.now().difference(_startTime!);
      });
    });
  }

  void _stopSession() {
    if (_count > 0) {
      ref.read(kickCounterProvider.notifier).saveSession(_count, _duration);
    }
    _timer?.cancel();
    setState(() {
      _isSessionActive = false;
    });
  }

  void _recordKick() {
    if (!_isSessionActive) {
      _startSession();
    }
    setState(() {
      _count++;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(kickCounterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('কিক কাউন্টার'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSessionActive)
                  Text(
                    'সময়: ${_formatDuration(_duration)}',
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                const SizedBox(height: 20),
                Text(
                  '$_count',
                  style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                ),
                const Text('টি কিক পাওয়া গেছে', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _recordKick,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.pinkAccent, width: 2),
                    ),
                    child: const Icon(Icons.touch_app, size: 60, color: Colors.pinkAccent),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isSessionActive)
                  ElevatedButton(
                    onPressed: _stopSession,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text('সেশন শেষ করুন'),
                  ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('সাম্প্রতিক রেকর্ড', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final session = history[history.length - 1 - index];
                return ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text('${session.count} টি কিক'),
                  subtitle: Text(DateFormat('dd MMM, hh:mm a').format(session.startTime)),
                  trailing: Text(_formatDuration(session.duration)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

