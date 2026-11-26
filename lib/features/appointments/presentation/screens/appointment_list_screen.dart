import 'package:material_ui/material_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/hive_service.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../shared/models/appointment.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late final Box<Appointment> _box;

  @override
  void initState() {
    super.initState();
    _box = HiveService.getBox<Appointment>(HiveService.appointmentBoxName);
  }

  Future<void> _edit({Appointment? appointment}) async {
    final title = TextEditingController(text: appointment?.title ?? '');
    final doctor = TextEditingController(text: appointment?.doctorName ?? '');
    final location = TextEditingController(text: appointment?.location ?? '');
    final notes = TextEditingController(text: appointment?.notes ?? '');
    var dateTime =
        appointment?.dateTime ?? DateTime.now().add(const Duration(days: 1));
    if (!dateTime.isAfter(DateTime.now())) {
      dateTime = DateTime.now().add(const Duration(hours: 2));
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            appointment == null
                ? 'নতুন অ্যাপয়েন্টমেন্ট'
                : 'অ্যাপয়েন্টমেন্ট সম্পাদনা',
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'কারণ / শিরোনাম *',
                    ),
                  ),
                  TextField(
                    controller: doctor,
                    decoration: const InputDecoration(
                      labelText: 'ডাক্তার (ঐচ্ছিক)',
                    ),
                  ),
                  TextField(
                    controller: location,
                    decoration: const InputDecoration(
                      labelText: 'স্থান (ঐচ্ছিক)',
                    ),
                  ),
                  TextField(
                    controller: notes,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'নোট (ঐচ্ছিক)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(dateTime),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date == null || !context.mounted) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(dateTime),
                      );
                      if (time != null) {
                        setDialogState(
                          () => dateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('বাতিল'),
            ),
            FilledButton(
              onPressed: title.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: const Text('সংরক্ষণ'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && title.text.trim().isNotEmpty) {
      if (appointment == null) {
        final item = Appointment(
          title: title.text.trim(),
          dateTime: dateTime,
          doctorName: _nullable(doctor.text),
          location: _nullable(location.text),
          notes: _nullable(notes.text),
        );
        await _box.add(item);
        await NotificationService.instance.requestPermissions();
        await NotificationService.instance.scheduleAppointment(item);
      } else {
        appointment
          ..title = title.text.trim()
          ..dateTime = dateTime
          ..doctorName = _nullable(doctor.text)
          ..location = _nullable(location.text)
          ..notes = _nullable(notes.text)
          ..isCompleted = false;
        await appointment.save();
        await NotificationService.instance.scheduleAppointment(appointment);
      }
    }
    title.dispose();
    doctor.dispose();
    location.dispose();
    notes.dispose();
  }

  String? _nullable(String value) => value.trim().isEmpty ? null : value.trim();

  Future<void> _delete(Appointment appointment) async {
    await NotificationService.instance.cancelAppointment(appointment);
    await appointment.delete();
  }

  Future<void> _toggleCompleted(Appointment appointment, bool value) async {
    appointment.isCompleted = value;
    await appointment.save();
    if (value) {
      await NotificationService.instance.cancelAppointment(appointment);
    } else {
      await NotificationService.instance.scheduleAppointment(appointment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ডাক্তারের অ্যাপয়েন্টমেন্ট')),
      body: ValueListenableBuilder<Box<Appointment>>(
        valueListenable: _box.listenable(),
        builder: (context, box, _) {
          final appointments = box.values.toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
          if (appointments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('এখনো কোনো অ্যাপয়েন্টমেন্ট যোগ করা হয়নি।'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final item = appointments[index];
              return Card(
                child: ListTile(
                  leading: Checkbox(
                    value: item.isCompleted,
                    onChanged: (value) =>
                        _toggleCompleted(item, value ?? false),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    [
                      DateFormat('dd MMM yyyy, hh:mm a').format(item.dateTime),
                      if (item.doctorName != null) 'ডা. ${item.doctorName}',
                      if (item.location != null) item.location!,
                    ].join('\n'),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _edit(appointment: item);
                      if (value == 'delete') _delete(item);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
                      PopupMenuItem(value: 'delete', child: Text('মুছে ফেলুন')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('অ্যাপয়েন্টমেন্ট যোগ'),
      ),
    );
  }
}
