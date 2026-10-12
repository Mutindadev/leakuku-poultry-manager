// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 3;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uid: fields[0] as String,
      phonenumber: fields[1] as String,
      email: fields[2] as String,
      name: fields[3] as String,
      role: fields[4] as String,
      flockIds: (fields[5] as List).cast<String>(),
      activeFlocks: (fields[6] as List).cast<String>(),
      fcmToken: fields[7] as String,
      isOnline: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      lastSyncedAt: fields[11] as DateTime,
      lastLocalModifiedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.phonenumber)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.flockIds)
      ..writeByte(6)
      ..write(obj.activeFlocks)
      ..writeByte(7)
      ..write(obj.fcmToken)
      ..writeByte(8)
      ..write(obj.isOnline)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.lastSyncedAt)
      ..writeByte(12)
      ..write(obj.lastLocalModifiedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
