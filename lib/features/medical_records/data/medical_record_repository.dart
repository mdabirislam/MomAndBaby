import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/database/hive_service.dart';
import '../../../shared/models/medical_record.dart';

class MedicalRecordRepository {
  final Box<MedicalRecord> _recordBox = HiveService.getBox<MedicalRecord>(
    HiveService.medicalRecordBoxName,
  );

  Future<void> addRecord(MedicalRecord record) async {
    await _recordBox.add(record);
  }

  /// Deletes the exact Hive object, regardless of its position in a sorted UI list.
  Future<void> deleteRecord(MedicalRecord record) async {
    await record.delete();
  }

  List<MedicalRecord> getAllRecords() {
    final records = _recordBox.values.toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }
}
