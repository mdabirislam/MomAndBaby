// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 4;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      name: fields[0] as String,
      dosage: fields[1] as String,
      reminderTimes: (fields[2] as List).cast<DateTime>(),
      isActive: fields[3] as bool,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dosage)
      ..writeByte(2)
      ..write(obj.reminderTimes)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicineLogAdapter extends TypeAdapter<MedicineLog> {
  @override
  final int typeId = 5;

  @override
  MedicineLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineLog(
      medicineId: fields[0] as String,
      takenAt: fields[1] as DateTime,
      scheduledTime: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.medicineId)
      ..writeByte(1)
      ..write(obj.takenAt)
      ..writeByte(2)
      ..write(obj.scheduledTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
