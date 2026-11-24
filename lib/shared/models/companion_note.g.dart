// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_note.dart';

class CompanionNoteAdapter extends TypeAdapter<CompanionNote> {
  @override
  final int typeId = 10;

  @override
  CompanionNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanionNote(
      title: fields[0] as String,
      content: fields[1] as String,
      author: fields[2] as String,
      category: fields[3] as String,
      createdAt: fields[4] as DateTime,
      isPinned: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CompanionNote obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isPinned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanionNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
