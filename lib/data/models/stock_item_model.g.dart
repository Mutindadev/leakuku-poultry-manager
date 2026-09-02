// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockItemModelAdapter extends TypeAdapter<StockItemModel> {
  @override
  final int typeId = 13;

  @override
  StockItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockItemModel(
      id: fields[0] as String,
      category: fields[1] as String,
      name: fields[2] as String,
      quantity: fields[3] as double,
      unit: fields[4] as String,
      minimumLevel: fields[5] as double,
      lastUpdated: fields[6] as DateTime,
      expiryDate: fields[7] as DateTime?,
      supplier: fields[8] as String?,
      cost: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, StockItemModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.minimumLevel)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.expiryDate)
      ..writeByte(8)
      ..write(obj.supplier)
      ..writeByte(9)
      ..write(obj.cost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
