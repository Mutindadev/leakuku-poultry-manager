// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flock_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlockModelAdapter extends TypeAdapter<FlockModel> {
  @override
  final int typeId = 1;

  @override
  FlockModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlockModel(
      id: fields[0] as String,
      name: fields[1] as String,
      breed: fields[2] as String,
      quantity: fields[3] as int,
      purchaseDate: fields[4] as DateTime,
      notes: fields[5] as String?,
      userId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FlockModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.breed)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.purchaseDate)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlockModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlockModel _$FlockModelFromJson(Map<String, dynamic> json) => FlockModel(
      id: json['id'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      quantity: (json['quantity'] as num).toInt(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      notes: json['notes'] as String?,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$FlockModelToJson(FlockModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'breed': instance.breed,
      'quantity': instance.quantity,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'notes': instance.notes,
      'userId': instance.userId,
    };
