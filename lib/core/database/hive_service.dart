import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../shared/models/user_profile.dart';
import '../../shared/models/daily_care.dart';
import '../../shared/models/medicine.dart';
import '../../shared/models/appointment.dart';
import '../../shared/models/diary_entry.dart';
import '../../shared/models/medical_record.dart';
import '../../shared/models/planner_task.dart';
import '../../shared/models/companion_note.dart';

class HiveService {
  static const String profileBoxName = 'profileBox';
  static const String waterBoxName = 'waterBox';
  static const String kickBoxName = 'kickBox';
  static const String symptomBoxName = 'symptomBox';
  static const String medicineBoxName = 'medicineBox';
  static const String medicineLogBoxName = 'medicineLogBox';
  static const String appointmentBoxName = 'appointmentBox';
  static const String diaryBoxName = 'diaryBox';
  static const String medicalRecordBoxName = 'medicalRecordBox';
  static const String plannerTaskBoxName = 'plannerTaskBox';
  static const String companionNoteBoxName = 'companionNoteBox';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register Adapters
      Hive.registerAdapter(UserProfileAdapter());
      Hive.registerAdapter(WaterLogAdapter());
      Hive.registerAdapter(KickCountAdapter());
      Hive.registerAdapter(SymptomLogAdapter());
      Hive.registerAdapter(MedicineAdapter());
      Hive.registerAdapter(MedicineLogAdapter());
      Hive.registerAdapter(AppointmentAdapter());
      Hive.registerAdapter(DiaryEntryAdapter());
      Hive.registerAdapter(MedicalRecordAdapter());
      Hive.registerAdapter(PlannerTaskAdapter());
      Hive.registerAdapter(CompanionNoteAdapter());

      // Open Boxes
      await Future.wait([
        Hive.openBox<UserProfile>(profileBoxName),
        Hive.openBox<WaterLog>(waterBoxName),
        Hive.openBox<KickCount>(kickBoxName),
        Hive.openBox<SymptomLog>(symptomBoxName),
        Hive.openBox<Medicine>(medicineBoxName),
        Hive.openBox<MedicineLog>(medicineLogBoxName),
        Hive.openBox<Appointment>(appointmentBoxName),
        Hive.openBox<DiaryEntry>(diaryBoxName),
        Hive.openBox<MedicalRecord>(medicalRecordBoxName),
        Hive.openBox<PlannerTask>(plannerTaskBoxName),
        Hive.openBox<CompanionNote>(companionNoteBoxName),
      ]);
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }

  static Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }
}
