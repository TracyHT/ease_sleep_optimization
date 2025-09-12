// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvDataAdapter extends TypeAdapter<EnvData> {
  @override
  final int typeId = 4;

  @override
  EnvData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnvData(
      sessionId: fields[0] as int?,
      userId: fields[1] as int?,
      timestamp: fields[2] as DateTime?,
      sensorType: fields[3] as String?,
      sensorValue: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, EnvData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.sensorType)
      ..writeByte(4)
      ..write(obj.sensorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
