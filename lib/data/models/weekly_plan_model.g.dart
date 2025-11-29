// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyPlanModelAdapter extends TypeAdapter<WeeklyPlanModel> {
  @override
  final int typeId = 12;

  @override
  WeeklyPlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyPlanModel(
      id: fields[0] as String,
      flockId: fields[1] as String,
      weekNumber: fields[2] as int,
      plannedFeedGramsPerBird: fields[3] as double,
      plannedTotalFeedKg: fields[4] as double,
      plannedWaterLiters: fields[5] as double,
      plannedBodyWeightKg: fields[6] as double,
      plannedTemperatureCelsius: fields[7] as double,
      plannedMortalityPercent: fields[8] as double,
      actualFeedGramsPerBird: fields[9] as double?,
      actualTotalFeedKg: fields[10] as double?,
      actualWaterLiters: fields[11] as double?,
      actualBodyWeightKg: fields[12] as double?,
      actualTemperatureCelsius: fields[13] as double?,
      actualMortalityPercent: fields[14] as double?,
      weekStartDate: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyPlanModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.flockId)
      ..writeByte(2)
      ..write(obj.weekNumber)
      ..writeByte(3)
      ..write(obj.plannedFeedGramsPerBird)
      ..writeByte(4)
      ..write(obj.plannedTotalFeedKg)
      ..writeByte(5)
      ..write(obj.plannedWaterLiters)
      ..writeByte(6)
      ..write(obj.plannedBodyWeightKg)
      ..writeByte(7)
      ..write(obj.plannedTemperatureCelsius)
      ..writeByte(8)
      ..write(obj.plannedMortalityPercent)
      ..writeByte(9)
      ..write(obj.actualFeedGramsPerBird)
      ..writeByte(10)
      ..write(obj.actualTotalFeedKg)
      ..writeByte(11)
      ..write(obj.actualWaterLiters)
      ..writeByte(12)
      ..write(obj.actualBodyWeightKg)
      ..writeByte(13)
      ..write(obj.actualTemperatureCelsius)
      ..writeByte(14)
      ..write(obj.actualMortalityPercent)
      ..writeByte(15)
      ..write(obj.weekStartDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyPlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
