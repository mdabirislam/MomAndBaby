import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/models/medical_record.dart';
import '../data/medical_record_repository.dart';

final medicalRecordRepositoryProvider = Provider(
  (ref) => MedicalRecordRepository(),
);

final medicalRecordsProvider =
    StateNotifierProvider<MedicalRecordsNotifier, List<MedicalRecord>>((ref) {
      return MedicalRecordsNotifier(ref.watch(medicalRecordRepositoryProvider));
    });

class MedicalRecordsNotifier extends StateNotifier<List<MedicalRecord>> {
  final MedicalRecordRepository _repository;

  MedicalRecordsNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.getAllRecords();
  }

  Future<void> addRecord(
    String title,
    String category,
    List<XFile> pickedImages, {
    String? notes,
  }) async {
    final savedPaths = await _repository.importPickedImages(pickedImages);
    final record = MedicalRecord(
      title: title,
      date: DateTime.now(),
      category: category,
      filePaths: savedPaths,
      notes: notes,
    );
    try {
      await _repository.addRecord(record);
    } catch (_) {
      // If Hive write fails, do not leave orphaned copies behind.
      await _repository.deleteImportedFiles(savedPaths);
      rethrow;
    }
    refresh();
  }

  Future<void> deleteRecord(MedicalRecord record) async {
    await _repository.deleteRecord(record);
    refresh();
  }
}
