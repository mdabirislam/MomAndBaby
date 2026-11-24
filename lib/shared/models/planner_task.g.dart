// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlannerTaskAdapter extends TypeAdapter<PlannerTask> {
  @override
  final int typeId = 9;

  @override
  PlannerTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannerTask(
      title: fields[0] as String,
      category: fields[1] as String,
      dueDate: fields[2] as DateTime?,
      notes: fields[3] as String?,
      isCompleted: fields[4] as bool,
      reminderAt: fields[5] as DateTime?,
      templateId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlannerTask obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.dueDate)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.reminderAt)
      ..writeByte(6)
      ..write(obj.templateId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannerTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
