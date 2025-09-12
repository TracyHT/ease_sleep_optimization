// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_quality_metrics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepQualityMetricsAdapter extends TypeAdapter<SleepQualityMetrics> {
  @override
  final int typeId = 3;

  @override
  SleepQualityMetrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepQualityMetrics(
      metricId: fields[0] as int?,
      sessionId: fields[1] as int?,
      totalSleepTime: fields[2] as DateTime?,
      sleepEfficiency: fields[3] as DateTime?,
      sleepOnsetLatency: fields[4] as DateTime?,
      timeInWake: fields[5] as double?,
      timeInN1: fields[6] as double?,
      timeInN2: fields[7] as double?,
      timeInN3: fields[8] as double?,
      timeInREM: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SleepQualityMetrics obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.metricId)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.totalSleepTime)
      ..writeByte(3)
      ..write(obj.sleepEfficiency)
      ..writeByte(4)
      ..write(obj.sleepOnsetLatency)
      ..writeByte(5)
      ..write(obj.timeInWake)
      ..writeByte(6)
      ..write(obj.timeInN1)
      ..writeByte(7)
      ..write(obj.timeInN2)
      ..writeByte(8)
      ..write(obj.timeInN3)
      ..writeByte(9)
      ..write(obj.timeInREM);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepQualityMetricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
