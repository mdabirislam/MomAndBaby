import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/medicine.dart';
import '../../../core/notifications/notification_service.dart';
import '../data/medicine_repository.dart';

final medicineRepositoryProvider = Provider<MedicineRepository>(
  (ref) => MedicineRepository(),
);

final medicinesProvider =
    StateNotifierProvider<MedicinesNotifier, List<Medicine>>((ref) {
      return MedicinesNotifier(ref.watch(medicineRepositoryProvider));
    });

class MedicinesNotifier extends StateNotifier<List<Medicine>> {
  MedicinesNotifier(this._repository) : super(const []) {
    refresh();
  }

  final MedicineRepository _repository;

  void refresh() => state = _repository.getAllMedicines();

  Future<void> addMedicine(Medicine medicine) async {
    await _repository.addMedicine(medicine);
    refresh();
    await NotificationService.instance.requestPermissions();
    await NotificationService.instance.scheduleMedicine(medicine);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await _repository.updateMedicine(medicine);
    refresh();
    await NotificationService.instance.scheduleMedicine(medicine);
  }

  Future<void> toggleMedicineStatus(Medicine medicine) async {
    medicine.isActive = !medicine.isActive;
    await _repository.updateMedicine(medicine);
    refresh();
    await NotificationService.instance.scheduleMedicine(medicine);
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    await NotificationService.instance.cancelMedicine(medicine);
    await _repository.deleteMedicine(medicine);
    refresh();
  }
}

final medicineLogsProvider =
    StateNotifierProvider<MedicineLogsNotifier, List<MedicineLog>>((ref) {
      return MedicineLogsNotifier(ref.watch(medicineRepositoryProvider));
    });

class MedicineLogsNotifier extends StateNotifier<List<MedicineLog>> {
  MedicineLogsNotifier(this._repository) : super(const []) {
    refresh();
  }

  final MedicineRepository _repository;

  void refresh() => state = _repository.getLogsForDate(DateTime.now());

  Future<void> takeMedicine({
    required String medicineId,
    required DateTime scheduledTime,
  }) async {
    if (_repository.isDoseTaken(
      medicineId: medicineId,
      date: DateTime.now(),
      scheduledTime: scheduledTime,
    ))
      return;
    await _repository.logMedicineTaken(
      medicineId: medicineId,
      scheduledTime: scheduledTime,
    );
    refresh();
  }
}
