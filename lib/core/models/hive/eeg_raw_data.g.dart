// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eeg_raw_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EegRawDataAdapter extends TypeAdapter<EegRawData> {
  @override
  final int typeId = 2;

  @override
  EegRawData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EegRawData(
      eegId: fields[0] as int?,
      sessionId: fields[1] as int?,
      deviceId: fields[2] as int?,
      startTime: fields[3] as DateTime?,
      endTime: fields[4] as DateTime?,
      dataFilePath: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EegRawData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.eegId)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.deviceId)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.dataFilePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EegRawDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
