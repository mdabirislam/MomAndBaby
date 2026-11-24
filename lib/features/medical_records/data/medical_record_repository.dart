import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/database/hive_service.dart';
import '../../../shared/models/medical_record.dart';
import 'medical_record_file_service.dart';

class MedicalRecordRepository {
  MedicalRecordRepository({MedicalRecordFileService? fileService})
    : _fileService = fileService ?? MedicalRecordFileService();

  final MedicalRecordFileService _fileService;

  Box<MedicalRecord> get _recordBox =>
      HiveService.getBox<MedicalRecord>(HiveService.medicalRecordBoxName);

  Future<List<String>> importPickedImages(List<XFile> images) {
    return _fileService.importImages(images);
  }

  Future<void> deleteImportedFiles(List<String> paths) {
    return _fileService.deleteManagedFiles(paths);
  }

  Future<void> addRecord(MedicalRecord record) async {
    await _recordBox.add(record);
  }

  /// Deletes the exact Hive object, then removes only files owned by this app.
  Future<void> deleteRecord(MedicalRecord record) async {
    final paths = List<String>.from(record.filePaths);
    await record.delete();
    await _fileService.deleteManagedFiles(paths);
  }

  List<MedicalRecord> getAllRecords() {
    final records = _recordBox.values.toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }
}
