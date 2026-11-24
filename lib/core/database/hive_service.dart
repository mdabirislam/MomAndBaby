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
    await Hive.openBox<UserProfile>(profileBoxName);
    await Hive.openBox<WaterLog>(waterBoxName);
    await Hive.openBox<KickCount>(kickBoxName);
    await Hive.openBox<SymptomLog>(symptomBoxName);
    await Hive.openBox<Medicine>(medicineBoxName);
    await Hive.openBox<MedicineLog>(medicineLogBoxName);
    await Hive.openBox<Appointment>(appointmentBoxName);
    await Hive.openBox<DiaryEntry>(diaryBoxName);
    await Hive.openBox<MedicalRecord>(medicalRecordBoxName);
    await Hive.openBox<PlannerTask>(plannerTaskBoxName);
    await Hive.openBox<CompanionNote>(companionNoteBoxName);
  }

  static Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }
}
