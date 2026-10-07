// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/hive_helper/fields/user_model_fields.dart';
import 'package:leakuku/hive_helper/hive_adapters.dart';
import 'package:leakuku/hive_helper/hive_types.dart';

part 'user.g.dart';

@HiveType(typeId: HiveTypes.userModel, adapterName: HiveAdapters.userModel)
class UserModel extends HiveObject {
  // @HiveField(UserModelFields.uid)
  @HiveField(UserModelFields.uid)
  String uid;

  // @HiveField(UserModelFields.phonenumber)
  @HiveField(UserModelFields.phonenumber)
  String phonenumber;
  // @HiveField(UserModelFields.email)
  @HiveField(UserModelFields.email)
  String email;
  @HiveField(UserModelFields.name)
  String name;
  @HiveField(UserModelFields.role)
  String role;
  // @HiveField(UserModelFields.profileIds)
  @HiveField(UserModelFields.flockIds)
  List<String> flockIds;
  @HiveField(UserModelFields.activeFlocks)
  List<String> activeFlocks;

  // @HiveField(UserModelFields.fcmToken)
  @HiveField(UserModelFields.fcmToken)
  String fcmToken;
  // @HiveField(UserModelFields.isOnline)
  @HiveField(UserModelFields.isOnline)
  bool isOnline;
  // @HiveField(UserModelFields.createdAt)
  @HiveField(UserModelFields.createdAt)
  DateTime createdAt;
  // @HiveField(UserModelFields.updatedAt)
  @HiveField(UserModelFields.updatedAt)
  DateTime updatedAt;

  // sync metadata
  @HiveField(UserModelFields.lastSyncedAt)
  DateTime lastSyncedAt;
  @HiveField(UserModelFields.lastLocalModifiedAt)
  DateTime lastLocalModifiedAt;

  UserModel({
    required this.uid,
    required this.phonenumber,
    required this.email,
    required this.name,
    required this.role,
    required this.flockIds,
    required this.activeFlocks,
    required this.fcmToken,
    required this.isOnline,
    required this.createdAt,
    required this.updatedAt,
    required this.lastSyncedAt,
    required this.lastLocalModifiedAt,
  });

  UserModel copyWith({
    String? uid,
    String? phonenumber,
    String? email,
    String? name,
    String? role,
    List<String>? flockIds,
    List<String>? activeFlocks,
    String? fcmToken,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    DateTime? lastLocalModifiedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phonenumber: phonenumber ?? this.phonenumber,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      flockIds: flockIds ?? this.flockIds,
      activeFlocks: activeFlocks ?? this.activeFlocks,
      fcmToken: fcmToken ?? this.fcmToken,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastLocalModifiedAt: lastLocalModifiedAt ?? this.lastLocalModifiedAt,
    );
  }

  static UserModel empty() {
    return UserModel(
      uid: '',
      phonenumber: '',
      email: '',
      name: '',
      role: '',
      flockIds: [],
      activeFlocks: [],
      fcmToken: '',
      isOnline: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastSyncedAt: DateTime.now(),
      lastLocalModifiedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'phonenumber': phonenumber,
      'email': email,
      'name': name,
      'role': role,
      'flockIds': flockIds,
      'activeFlocks': activeFlocks,
      'fcmToken': fcmToken,
      'isOnline': isOnline,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'lastSyncedAt': lastSyncedAt.millisecondsSinceEpoch,
      'lastLocalModifiedAt': lastLocalModifiedAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      phonenumber: map['phonenumber'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      flockIds: List<String>.from(map['flockIds'] as List? ?? const []),
      activeFlocks: List<String>.from(map['activeFlocks'] as List? ?? const []),
      fcmToken: map['fcmToken'] as String,
      isOnline: map['isOnline'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      lastSyncedAt:
          DateTime.fromMillisecondsSinceEpoch(map['lastSyncedAt'] as int),
      lastLocalModifiedAt: DateTime.fromMillisecondsSinceEpoch(
          map['lastLocalModifiedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, phonenumber: $phonenumber, email: $email, name: $name, role: $role, flockIds: $flockIds, activeFlocks: $activeFlocks, fcmToken: $fcmToken, isOnline: $isOnline, createdAt: $createdAt, updatedAt: $updatedAt, lastSyncedAt: $lastSyncedAt, lastLocalModifiedAt: $lastLocalModifiedAt)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.phonenumber == phonenumber &&
        other.email == email &&
        other.name == name &&
        other.role == role &&
        listEquals(other.flockIds, flockIds) &&
        listEquals(other.activeFlocks, activeFlocks) &&
        other.fcmToken == fcmToken &&
        other.isOnline == isOnline &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastSyncedAt == lastSyncedAt &&
        other.lastLocalModifiedAt == lastLocalModifiedAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        phonenumber.hashCode ^
        email.hashCode ^
        name.hashCode ^
        role.hashCode ^
        flockIds.hashCode ^
        activeFlocks.hashCode ^
        fcmToken.hashCode ^
        isOnline.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        lastSyncedAt.hashCode ^
        lastLocalModifiedAt.hashCode;
  }
}
