// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockHistoryModelAdapter extends TypeAdapter<StockHistoryModel> {
  @override
  final int typeId = 14;

  @override
  StockHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockHistoryModel(
      id: fields[0] as String,
      itemId: fields[1] as String,
      category: fields[2] as String,
      itemName: fields[3] as String,
      action: fields[4] as String,
      quantity: fields[5] as double,
      unit: fields[6] as String,
      date: fields[7] as DateTime,
      balanceAfter: fields[8] as double,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockHistoryModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemId)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.itemName)
      ..writeByte(4)
      ..write(obj.action)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.balanceAfter)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
