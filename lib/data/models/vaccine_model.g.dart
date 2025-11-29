// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineModelAdapter extends TypeAdapter<VaccineModel> {
  @override
  final int typeId = 11;

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
    );
  }

  @override
  void write(BinaryWriter writer, VaccineModel obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.breedId);
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
