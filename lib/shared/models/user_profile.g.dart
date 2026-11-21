// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      lmp: fields[1] as DateTime,
      eddOverride: fields[2] as DateTime?,
      welcomeMessage: fields[3] as String?,
      doctorName: fields[4] as String?,
      doctorPhone: fields[5] as String?,
      emergencyContactName: fields[6] as String?,
      emergencyContactPhone: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.lmp)
      ..writeByte(2)
      ..write(obj.eddOverride)
      ..writeByte(3)
      ..write(obj.welcomeMessage)
      ..writeByte(4)
      ..write(obj.doctorName)
      ..writeByte(5)
      ..write(obj.doctorPhone)
      ..writeByte(6)
      ..write(obj.emergencyContactName)
      ..writeByte(7)
      ..write(obj.emergencyContactPhone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
