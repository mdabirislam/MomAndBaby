import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    List<String> filePaths, {
    String? notes,
  }) async {
    final record = MedicalRecord(
      title: title,
      date: DateTime.now(),
      category: category,
      filePaths: filePaths,
      notes: notes,
    );
    await _repository.addRecord(record);
    refresh();
  }

  Future<void> deleteRecord(MedicalRecord record) async {
    await _repository.deleteRecord(record);
    refresh();
  }
}
