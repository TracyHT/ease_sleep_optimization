// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepSessionAdapter extends TypeAdapter<SleepSession> {
  @override
  final int typeId = 0;

  @override
  SleepSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepSession(
      sessionId: fields[0] as int?,
      firebaseUid: fields[1] as String?,
      startTime: fields[2] as DateTime?,
      endTime: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SleepSession obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.firebaseUid)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
