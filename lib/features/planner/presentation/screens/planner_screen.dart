import 'package:material_ui/material_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/hive_service.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/services/pregnancy_calculator.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/models/planner_task.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../appointments/presentation/screens/appointment_list_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late final Box<PlannerTask> _taskBox;
  late final Box<UserProfile> _profileBox;
  late final Box<Appointment> _appointmentBox;
  String _filter = 'all';

  static const _hospitalItems = <String>[
    'মায়ের প্রয়োজনীয় পোশাক ও আরামদায়ক স্যান্ডেল',
    'মাতৃত্বকালীন/হাসপাতালের কাগজপত্র ও পরিচয়পত্র',
    'চিকিৎসকের রিপোর্ট, আল্ট্রাসাউন্ড ও প্রেসক্রিপশন',
    'ব্যক্তিগত পরিচ্ছন্নতার সামগ্রী',
    'মোবাইল ফোন ও চার্জার',
    'শিশুর পোশাক, টুপি ও মোজা',
    'শিশুর ডায়াপার ও প্রয়োজনীয় কাপড়',
    'বাড়ি ফেরার জন্য মা ও শিশুর পোশাক',
  ];

  static const _deliveryItems = <String>[
    'প্রসব পরিকল্পনা নিয়ে চিকিৎসকের সঙ্গে আলোচনা',
    'হাসপাতাল/প্রসবকেন্দ্র ও যাতায়াতের ব্যবস্থা ঠিক করা',
    'জরুরি যোগাযোগ নম্বর প্রস্তুত রাখা',
    'সঙ্গী/সহায়তাকারীর দায়িত্ব ঠিক করা',
    'হাসপাতালের ভর্তি ও খরচের নিয়ম জেনে রাখা',
    'হাসপাতালের ব্যাগ প্রস্তুত রাখা',
    'প্রসব-পরবর্তী সহায়তা ও শিশুর যত্নের ব্যবস্থা করা',
  ];

  @override
  void initState() {
    super.initState();
    _taskBox = HiveService.getBox<PlannerTask>(HiveService.plannerTaskBoxName);
    _profileBox = HiveService.getBox<UserProfile>(HiveService.profileBoxName);
    _appointmentBox = HiveService.getBox<Appointment>(
      HiveService.appointmentBoxName,
    );
    _seedChecklist();
  }

  Future<void> _seedChecklist() async {
    final existing = _taskBox.values
        .map((task) => task.templateId)
        .whereType<String>()
        .toSet();
    final additions = <PlannerTask>[];
    for (var i = 0; i < _hospitalItems.length; i++) {
      final id = 'hospital_$i';
      if (!existing.contains(id)) {
        additions.add(
          PlannerTask(
            title: _hospitalItems[i],
            category: 'hospital',
            templateId: id,
          ),
        );
      }
    }
    for (var i = 0; i < _deliveryItems.length; i++) {
      final id = 'delivery_$i';
      if (!existing.contains(id)) {
        additions.add(
          PlannerTask(
            title: _deliveryItems[i],
            category: 'delivery',
            templateId: id,
          ),
        );
      }
    }
    if (additions.isNotEmpty) await _taskBox.addAll(additions);
  }

  Future<void> _addTask({PlannerTask? task}) async {
    final title = TextEditingController(text: task?.title ?? '');
    final notes = TextEditingController(text: task?.notes ?? '');
    var category = task?.category ?? 'task';
    var dueDate = task?.dueDate;
    var reminderAt = task?.reminderAt;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(task == null ? 'নতুন পরিকল্পনা' : 'পরিকল্পনা সম্পাদনা'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    autofocus: true,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(labelText: 'শিরোনাম *'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'ধরন'),
                    items: const [
                      DropdownMenuItem(
                        value: 'task',
                        child: Text('ব্যক্তিগত কাজ'),
                      ),
                      DropdownMenuItem(
                        value: 'test',
                        child: Text('টেস্ট / স্ক্যান'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => category = value);
                    },
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
                    leading: const Icon(Icons.event_outlined),
                    title: Text(
                      dueDate == null
                          ? 'তারিখ নির্ধারণ করুন'
                          : DateFormat('dd MMM yyyy').format(dueDate!),
                    ),
                    trailing: dueDate == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setDialogState(() => dueDate = null),
                          ),
                    onTap: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (selected != null) {
                        setDialogState(() => dueDate = selected);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(
                      reminderAt == null
                          ? 'রিমাইন্ডার যোগ করুন'
                          : DateFormat('dd MMM, hh:mm a').format(reminderAt!),
                    ),
                    trailing: reminderAt == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setDialogState(() => reminderAt = null),
                          ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: reminderAt ?? dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date == null || !context.mounted) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: reminderAt == null
                            ? TimeOfDay.now()
                            : TimeOfDay.fromDateTime(reminderAt!),
                      );
                      if (time != null) {
                        setDialogState(
                          () => reminderAt = DateTime(
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
                  const Text(
                    'রিমাইন্ডার পেতে নোটিফিকেশন ও সঠিক অ্যালার্মের অনুমতি চালু থাকতে হবে।',
                    style: TextStyle(fontSize: 12),
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
      if (task == null) {
        final item = PlannerTask(
          title: title.text.trim(),
          category: category,
          dueDate: dueDate,
          notes: _nullable(notes.text),
          reminderAt: reminderAt,
        );
        await _taskBox.add(item);
        if (reminderAt != null) {
          await NotificationService.instance.requestPermissions();
          await NotificationService.instance.schedulePlannerTask(item);
        }
      } else {
        task
          ..title = title.text.trim()
          ..category = category
          ..dueDate = dueDate
          ..notes = _nullable(notes.text)
          ..reminderAt = reminderAt;
        await task.save();
        await NotificationService.instance.cancelPlannerTask(task);
        if (reminderAt != null) {
          await NotificationService.instance.schedulePlannerTask(task);
        }
      }
    }
    title.dispose();
    notes.dispose();
  }

  String? _nullable(String value) => value.trim().isEmpty ? null : value.trim();

  Future<void> _openAppointments() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppointmentListScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggle(PlannerTask task, bool value) async {
    task.isCompleted = value;
    await task.save();
    if (value) {
      await NotificationService.instance.cancelPlannerTask(task);
    } else {
      await NotificationService.instance.schedulePlannerTask(task);
    }
  }

  Future<void> _delete(PlannerTask task) async {
    await NotificationService.instance.cancelPlannerTask(task);
    await task.delete();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileBox.isEmpty ? null : _profileBox.getAt(0);
    final appointments =
        _appointmentBox.values
            .where(
              (item) =>
                  !item.isCompleted && item.dateTime.isAfter(DateTime.now()),
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      appBar: AppBar(title: const Text('পরিকল্পনা')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTask(),
        icon: const Icon(Icons.add),
        label: const Text('নতুন কাজ'),
      ),
      body: ValueListenableBuilder<Box<PlannerTask>>(
        valueListenable: _taskBox.listenable(),
        builder: (context, box, _) {
          final tasks = box.values.toList();
          final hospital = tasks
              .where((e) => e.category == 'hospital')
              .toList();
          final delivery = tasks
              .where((e) => e.category == 'delivery')
              .toList();
          final custom =
              tasks
                  .where((e) => e.category == 'task' || e.category == 'test')
                  .toList()
                ..sort((a, b) {
                  if (a.dueDate == null && b.dueDate == null) return 0;
                  if (a.dueDate == null) return 1;
                  if (b.dueDate == null) return -1;
                  return a.dueDate!.compareTo(b.dueDate!);
                });
          final visible = _filter == 'all'
              ? custom
              : custom.where((e) => e.category == _filter).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              _PregnancyTimeline(profile: profile),
              const SizedBox(height: 12),
              _PlannerSection(
                title: 'ডাক্তারের অ্যাপয়েন্টমেন্ট',
                subtitle: appointments.isEmpty
                    ? 'কোনো আসন্ন অ্যাপয়েন্টমেন্ট নেই'
                    : 'পরবর্তী: ${appointments.first.title} · ${DateFormat('dd MMM, hh:mm a').format(appointments.first.dateTime)}',
                icon: Icons.event_available,
                actionLabel: 'সব দেখুন',
                onTap: _openAppointments,
              ),
              const SizedBox(height: 12),
              _ChecklistSection(
                title: 'হাসপাতালের ব্যাগ',
                subtitle: 'প্রয়োজনীয় জিনিসপত্র প্রস্তুত করুন',
                icon: Icons.local_hospital_outlined,
                tasks: hospital,
                onToggle: _toggle,
              ),
              const SizedBox(height: 12),
              _ChecklistSection(
                title: 'প্রসবের প্রস্তুতি',
                subtitle: 'আগে থেকে প্রয়োজনীয় ব্যবস্থা',
                icon: Icons.checklist_rtl,
                tasks: delivery,
                onToggle: _toggle,
              ),
              const SizedBox(height: 16),
              Text(
                'টেস্ট, স্ক্যান ও ব্যক্তিগত কাজ',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('সব')),
                  ButtonSegment(value: 'test', label: Text('টেস্ট/স্ক্যান')),
                  ButtonSegment(value: 'task', label: Text('অন্যান্য')),
                ],
                selected: {_filter},
                onSelectionChanged: (value) =>
                    setState(() => _filter = value.first),
              ),
              const SizedBox(height: 8),
              if (visible.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'এখনো কোনো কাজ যোগ করা হয়নি। + বোতামে চাপ দিয়ে যোগ করুন।',
                    ),
                  ),
                )
              else
                ...visible.map(
                  (task) => _TaskTile(
                    task: task,
                    onToggle: (value) => _toggle(task, value),
                    onEdit: () => _addTask(task: task),
                    onDelete: () => _delete(task),
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                'টেস্ট ও স্ক্যানের সময়সূচি চিকিৎসকের পরামর্শ অনুযায়ী নির্ধারণ করুন। এই তালিকা চিকিৎসকের নির্দেশের বিকল্প নয়।',
                style: TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PregnancyTimeline extends StatelessWidget {
  const _PregnancyTimeline({required this.profile});
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.timeline),
          title: Text('গর্ভাবস্থার টাইমলাইন'),
          subtitle: Text(
            'টাইমলাইন দেখতে প্রথমে প্রোফাইলে শেষ মাসিকের তারিখ (LMP) যোগ করুন।',
          ),
        ),
      );
    }
    final lmp = profile!.lmp;
    final days = PregnancyCalculator.calculateGestationalDays(lmp);
    final weeks = (days ~/ 7).clamp(0, 42);
    final day = days < 0 ? 0 : days % 7;
    final edd = profile!.eddOverride ?? PregnancyCalculator.calculateEDD(lmp);
    final milestones = [12, 20, 28, 36];
    final next = milestones.firstWhere(
      (week) => week > weeks,
      orElse: () => 40,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline),
                const SizedBox(width: 8),
                Text(
                  'গর্ভাবস্থার টাইমলাইন',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$weeks সপ্তাহ $day দিন',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'সম্ভাব্য প্রসবের তারিখ: ${DateFormat('dd MMMM yyyy').format(edd)}',
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: (days / 280).clamp(0.0, 1.0)),
            const SizedBox(height: 8),
            Text(
              weeks >= 40
                  ? 'সম্ভাব্য প্রসবের তারিখের সময়সীমা চলছে। চিকিৎসকের সঙ্গে যোগাযোগ রাখুন।'
                  : 'পরবর্তী পরিকল্পিত মাইলস্টোন: প্রায় $next সপ্তাহ',
            ),
            const SizedBox(height: 4),
            const Text(
              'তারিখ ও গর্ভকাল আনুমানিক হিসাব। চিকিৎসকের নির্ধারিত তারিখ ভিন্ন হতে পারে।',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerSection extends StatelessWidget {
  const _PlannerSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: onTap, child: Text(actionLabel)),
      onTap: onTap,
    ),
  );
}

class _ChecklistSection extends StatelessWidget {
  const _ChecklistSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tasks,
    required this.onToggle,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final List<PlannerTask> tasks;
  final ValueChanged2<PlannerTask, bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((task) => task.isCompleted).length;
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text('$subtitle · $completed/${tasks.length} সম্পন্ন'),
        children: tasks
            .map(
              (task) => CheckboxListTile(
                value: task.isCompleted,
                onChanged: (value) => onToggle(task, value ?? false),
                title: Text(task.title),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            )
            .toList(),
      ),
    );
  }
}

typedef ValueChanged2<T, V> = void Function(T value, V second);

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });
  final PlannerTask task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (value) => onToggle(value ?? false),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        [
          task.category == 'test' ? 'টেস্ট / স্ক্যান' : 'ব্যক্তিগত কাজ',
          if (task.dueDate != null)
            DateFormat('dd MMM yyyy').format(task.dueDate!),
          if (task.reminderAt != null)
            'রিমাইন্ডার: ${DateFormat('dd MMM, hh:mm a').format(task.reminderAt!)}',
          if (task.notes != null) task.notes!,
        ].join(' · '),
      ),
      isThreeLine: true,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
          PopupMenuItem(value: 'delete', child: Text('মুছে ফেলুন')),
        ],
      ),
    ),
  );
}
