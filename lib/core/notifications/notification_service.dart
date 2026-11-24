import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/database/hive_service.dart';
import '../../shared/models/appointment.dart';
import '../../shared/models/medicine.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _medicineChannel = AndroidNotificationDetails(
    'medicine_reminders',
    'Medicine reminders',
    channelDescription: 'Reminders for medicines added by the user',
    importance: Importance.max,
    priority: Priority.high,
  );
  static const _appointmentChannel = AndroidNotificationDetails(
    'appointment_reminders',
    'Appointment reminders',
    channelDescription: 'Upcoming appointment reminders',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _careChannel = AndroidNotificationDetails(
    'daily_care_reminders',
    'Daily care reminders',
    channelDescription: 'Optional daily care reminders',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  bool _initialized = false;
  bool _permissionGrantedThisSession = false;
  bool _notificationPermissionGrantedThisSession = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    // The app currently targets Bangladesh. Keep notification times aligned
    // with Bangladesh local time; this can be made device-timezone aware later.
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final notificationsGranted =
        await android?.requestNotificationsPermission() ?? true;
    final exactGranted = await android?.requestExactAlarmsPermission() ?? true;
    _notificationPermissionGrantedThisSession = notificationsGranted;
    _permissionGrantedThisSession = notificationsGranted && exactGranted;
    return _permissionGrantedThisSession;
  }

  Future<bool> requestNotificationPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission() ?? true;
    _notificationPermissionGrantedThisSession = granted;
    return granted;
  }

  Future<void> rescheduleAll() async {
    await initialize();
    if (!await _hasSchedulingPermission()) return;
    final medicineBox = HiveService.getBox<Medicine>(
      HiveService.medicineBoxName,
    );
    for (final medicine in medicineBox.values) {
      await scheduleMedicine(medicine);
    }

    final appointmentBox = HiveService.getBox<Appointment>(
      HiveService.appointmentBoxName,
    );
    for (final appointment in appointmentBox.values) {
      await scheduleAppointment(appointment);
    }
  }

  Future<void> scheduleMedicine(Medicine medicine) async {
    await initialize();
    final key = medicine.key;
    if (key == null) return;
    // Clear this medicine's previously planned notifications first.
    for (var day = 0; day < 14; day++) {
      for (var slot = 0; slot < 10; slot++) {
        await _plugin.cancel(_medicineId(key, day, slot));
      }
    }
    if (!medicine.isActive || medicine.reminderTimes.isEmpty) return;
    if (!await _hasSchedulingPermission()) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var day = 0; day < 14; day++) {
      final date = today.add(Duration(days: day));
      if (date.isBefore(
        DateTime(
          medicine.startDate.year,
          medicine.startDate.month,
          medicine.startDate.day,
        ),
      )) {
        continue;
      }
      if (medicine.endDate != null &&
          date.isAfter(
            DateTime(
              medicine.endDate!.year,
              medicine.endDate!.month,
              medicine.endDate!.day,
            ),
          )) {
        continue;
      }
      for (var slot = 0; slot < medicine.reminderTimes.length; slot++) {
        final time = medicine.reminderTimes[slot];
        final scheduled = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        if (!scheduled.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          _medicineId(key, day, slot),
          'ওষুধ গ্রহণের সময়',
          '${medicine.name}${medicine.dosage.isEmpty ? '' : ' — ${medicine.dosage}'}',
          tz.TZDateTime.from(scheduled, tz.local),
          const NotificationDetails(android: _medicineChannel),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelMedicine(Medicine medicine) async {
    await initialize();
    if (medicine.key == null) return;
    for (var day = 0; day < 14; day++) {
      for (var slot = 0; slot < 10; slot++) {
        await _plugin.cancel(_medicineId(medicine.key, day, slot));
      }
    }
  }

  Future<void> scheduleAppointment(Appointment appointment) async {
    await initialize();
    if (appointment.key == null) return;
    final baseId =
        500000 + (_stableId('appointment:${appointment.key}') % 400000);
    await _plugin.cancel(baseId);
    await _plugin.cancel(baseId + 1);
    if (!await _hasSchedulingPermission()) return;
    if (appointment.isCompleted ||
        !appointment.dateTime.isAfter(DateTime.now())) {
      return;
    }
    final oneDayBefore = appointment.dateTime.subtract(const Duration(days: 1));
    final twoHoursBefore = appointment.dateTime.subtract(
      const Duration(hours: 2),
    );
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        baseId,
        'আগামীকাল অ্যাপয়েন্টমেন্ট',
        appointment.title,
        tz.TZDateTime.from(oneDayBefore, tz.local),
        const NotificationDetails(android: _appointmentChannel),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
    if (twoHoursBefore.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        baseId + 1,
        'অ্যাপয়েন্টমেন্টের সময় কাছাকাছি',
        appointment.title,
        tz.TZDateTime.from(twoHoursBefore, tz.local),
        const NotificationDetails(android: _appointmentChannel),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelAppointment(Appointment appointment) async {
    await initialize();
    if (appointment.key == null) return;
    final id = 500000 + (_stableId('appointment:${appointment.key}') % 400000);
    await _plugin.cancel(id);
    await _plugin.cancel(id + 1);
  }

  Future<void> setWaterReminders(bool enabled) async {
    await initialize();
    if (enabled && !await _hasNotificationPermission()) return;
    const hours = [9, 11, 13, 15, 17, 19, 21];
    for (final hour in hours) {
      final id = 700000 + hour;
      await _plugin.cancel(id);
      if (enabled) {
        final now = DateTime.now();
        var next = DateTime(now.year, now.month, now.day, hour);
        if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
        await _plugin.zonedSchedule(
          id,
          'একটু পানি পান করুন',
          'আপনার সুবিধামতো পানি পান করুন। চিকিৎসকের দেওয়া তরল-সংক্রান্ত নির্দেশনা মেনে চলুন।',
          tz.TZDateTime.from(next, tz.local),
          const NotificationDetails(android: _careChannel),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }

  Future<bool> _hasNotificationPermission() async {
    if (_notificationPermissionGrantedThisSession) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    return await android.areNotificationsEnabled() ?? true;
  }

  Future<bool> _hasSchedulingPermission() async {
    if (_permissionGrantedThisSession) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    final notificationsEnabled =
        await android.areNotificationsEnabled() ?? true;
    final exactAllowed = await android.canScheduleExactNotifications() ?? true;
    return notificationsEnabled && exactAllowed;
  }

  int _medicineId(Object key, int day, int slot) =>
      100000 + (_stableId('medicine:$key') % 300000) + day * 10 + slot;

  int _stableId(String value) {
    var hash = 2166136261;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0x7fffffff;
    }
    return hash % 1000000000;
  }
}
