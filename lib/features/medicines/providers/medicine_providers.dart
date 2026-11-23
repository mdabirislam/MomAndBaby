import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/medicine_repository.dart';
import '../../../shared/models/medicine.dart';

final medicineRepositoryProvider = Provider((ref) => MedicineRepository());

final medicinesProvider = StateNotifierProvider<MedicinesNotifier, List<Medicine>>((ref) {
  return MedicinesNotifier(ref.watch(medicineRepositoryProvider));
});

class MedicinesNotifier extends StateNotifier<List<Medicine>> {
  final MedicineRepository _repository;

  MedicinesNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.getAllMedicines();
  }

  Future<void> addMedicine(Medicine medicine) async {
    await _repository.addMedicine(medicine);
    refresh();
  }

  Future<void> toggleMedicineStatus(int index) async {
    final med = state[index];
    med.isActive = !med.isActive;
    await _repository.updateMedicine(index, med);
    refresh();
  }

  Future<void> deleteMedicine(int index) async {
    await _repository.deleteMedicine(index);
    refresh();
  }
}

final medicineLogsProvider = StateNotifierProvider<MedicineLogsNotifier, List<MedicineLog>>((ref) {
  return MedicineLogsNotifier(ref.watch(medicineRepositoryProvider));
});

class MedicineLogsNotifier extends StateNotifier<List<MedicineLog>> {
  final MedicineRepository _repository;

  MedicineLogsNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.getLogsForDate(DateTime.now());
  }

  Future<void> takeMedicine(String medicineId) async {
    await _repository.logMedicineTaken(medicineId, DateTime.now());
    refresh();
  }
}
