// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineModelAdapter extends TypeAdapter<VaccineModel> {
  @override
  final int typeId = 0;

  @override
  VaccineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineModel(
      id: fields[0] as String,
      dayOfCycle: fields[1] as int?,
      weekRange: fields[2] as String?,
      vaccineName: fields[3] as String,
      disease: fields[4] as String,
      application: fields[5] as String,
      isOptional: fields[6] as bool,
      breedId: fields[7] as String,
      flockId: fields[8] as String?,
      status: fields[9] as String,
      completedAt: fields[10] as DateTime?,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dayOfCycle)
      ..writeByte(2)
      ..write(obj.weekRange)
      ..writeByte(3)
      ..write(obj.vaccineName)
      ..writeByte(4)
      ..write(obj.disease)
      ..writeByte(5)
      ..write(obj.application)
      ..writeByte(6)
      ..write(obj.isOptional)
      ..writeByte(7)
      ..write(obj.breedId)
      ..writeByte(8)
      ..write(obj.flockId)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
