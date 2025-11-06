// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeekAdapter extends TypeAdapter<Week> {
  @override
  final int typeId = 2;

  @override
  Week read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Week(
      weekId: fields[0] as int,
      task: (fields[1] as List).cast<Task>(),
    );
  }

  @override
  void write(BinaryWriter writer, Week obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weekId)
      ..writeByte(1)
      ..write(obj.task);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeekAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
