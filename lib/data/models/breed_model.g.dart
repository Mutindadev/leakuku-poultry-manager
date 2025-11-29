// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breed_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreedModelAdapter extends TypeAdapter<BreedModel> {
  @override
  final int typeId = 10;

  @override
  BreedModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreedModel(
      id: fields[0] as String,
      name: fields[1] as String,
      purpose: fields[2] as String,
      keyBenefits: (fields[3] as List).cast<String>(),
      weeklyExpectedWeight: (fields[4] as Map).cast<int, double>(),
      weeklyFeedGrams: (fields[5] as Map).cast<int, double>(),
      expectedEggsPerYear: fields[6] as int?,
      cycleDurationDays: fields[7] as int,
      defaultFeedGramsPerWeek: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BreedModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.purpose)
      ..writeByte(3)
      ..write(obj.keyBenefits)
      ..writeByte(4)
      ..write(obj.weeklyExpectedWeight)
      ..writeByte(5)
      ..write(obj.weeklyFeedGrams)
      ..writeByte(6)
      ..write(obj.expectedEggsPerYear)
      ..writeByte(7)
      ..write(obj.cycleDurationDays)
      ..writeByte(8)
      ..write(obj.defaultFeedGramsPerWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreedModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
