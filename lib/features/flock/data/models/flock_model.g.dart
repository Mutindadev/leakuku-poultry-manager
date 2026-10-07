// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flock_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlockModelAdapter extends TypeAdapter<FlockModel> {
  @override
  final int typeId = 2;

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
      status: fields[7] as String,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      startedAt: fields[10] as DateTime,
      expectedEndDate: fields[11] as DateTime?,
      vaccineIds: (fields[12] as List?)?.cast<String>(),
      weeklyPlanIds: (fields[13] as List?)?.cast<String>(),
      dailyRecordsIds: (fields[14] as List?)?.cast<String>(),
      stockItemIds: (fields[15] as List?)?.cast<String>(),
      financeTransactionIds: (fields[16] as List?)?.cast<String>(),
      currentWeek: fields[17] as String,
      mortalityPercent: fields[18] as String,
      avgBirdWeightKg: fields[19] as String,
      feedConsumedKg: fields[20] as String,
      waterConsumedLiters: fields[21] as String,
      lowStockItemsCount: fields[22] as String,
      pendingVaccinesCount: fields[23] as String,
      lastDailyRecordDate: fields[24] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FlockModel obj) {
    writer
      ..writeByte(25)
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
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.startedAt)
      ..writeByte(11)
      ..write(obj.expectedEndDate)
      ..writeByte(12)
      ..write(obj.vaccineIds)
      ..writeByte(13)
      ..write(obj.weeklyPlanIds)
      ..writeByte(14)
      ..write(obj.dailyRecordsIds)
      ..writeByte(15)
      ..write(obj.stockItemIds)
      ..writeByte(16)
      ..write(obj.financeTransactionIds)
      ..writeByte(17)
      ..write(obj.currentWeek)
      ..writeByte(18)
      ..write(obj.mortalityPercent)
      ..writeByte(19)
      ..write(obj.avgBirdWeightKg)
      ..writeByte(20)
      ..write(obj.feedConsumedKg)
      ..writeByte(21)
      ..write(obj.waterConsumedLiters)
      ..writeByte(22)
      ..write(obj.lowStockItemsCount)
      ..writeByte(23)
      ..write(obj.pendingVaccinesCount)
      ..writeByte(24)
      ..write(obj.lastDailyRecordDate);
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
