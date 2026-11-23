import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/hive_service.dart';
import '../../../shared/models/medicine.dart';

class MedicineRepository {
  final Box<Medicine> _medicineBox = HiveService.getBox<Medicine>(HiveService.medicineBoxName);
  final Box<MedicineLog> _medicineLogBox = HiveService.getBox<MedicineLog>(HiveService.medicineLogBoxName);

  Future<void> addMedicine(Medicine medicine) async {
    await _medicineBox.add(medicine);
  }

  Future<void> updateMedicine(int index, Medicine medicine) async {
    await _medicineBox.putAt(index, medicine);
  }

  Future<void> deleteMedicine(int index) async {
    await _medicineBox.deleteAt(index);
  }

  List<Medicine> getAllMedicines() {
    return _medicineBox.values.toList();
  }

  Future<void> logMedicineTaken(String medicineId, DateTime takenAt) async {
    final log = MedicineLog(medicineId: medicineId, takenAt: takenAt);
    await _medicineLogBox.add(log);
  }

  List<MedicineLog> getLogsForDate(DateTime date) {
    return _medicineLogBox.values.where((log) {
      return log.takenAt.year == date.year &&
             log.takenAt.month == date.month &&
             log.takenAt.day == date.day;
    }).toList();
  }
}
