import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/database/hive_service.dart';
import '../../../shared/models/medicine.dart';

class MedicineRepository {
  final Box<Medicine> _medicineBox = HiveService.getBox<Medicine>(
    HiveService.medicineBoxName,
  );
  final Box<MedicineLog> _medicineLogBox = HiveService.getBox<MedicineLog>(
    HiveService.medicineLogBoxName,
  );

  Future<void> addMedicine(Medicine medicine) async {
    await _medicineBox.add(medicine);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await medicine.save();
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    final id = medicine.key.toString();
    final relatedLogs = _medicineLogBox.values
        .where((log) => log.medicineId == id)
        .toList();
    for (final log in relatedLogs) {
      await log.delete();
    }
    await medicine.delete();
  }

  List<Medicine> getAllMedicines() {
    final items = _medicineBox.values.toList();
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
  }

  Future<void> logMedicineTaken({
    required String medicineId,
    required DateTime scheduledTime,
    DateTime? takenAt,
  }) async {
    await _medicineLogBox.add(
      MedicineLog(
        medicineId: medicineId,
        takenAt: takenAt ?? DateTime.now(),
        scheduledTime: scheduledTime,
      ),
    );
  }

  List<MedicineLog> getLogsForDate(DateTime date) {
    final logs = _medicineLogBox.values
        .where((log) => _sameDate(log.takenAt, date))
        .toList();
    logs.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return logs;
  }

  bool isDoseTaken({
    required String medicineId,
    required DateTime date,
    required DateTime scheduledTime,
  }) {
    return _medicineLogBox.values.any(
      (log) =>
          log.medicineId == medicineId &&
          _sameDate(log.takenAt, date) &&
          log.scheduledTime != null &&
          log.scheduledTime!.hour == scheduledTime.hour &&
          log.scheduledTime!.minute == scheduledTime.minute,
    );
  }

  Future<void> deleteDoseLog(MedicineLog log) => log.delete();

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
