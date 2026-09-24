// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

// @HiveType(typeId: HiveTypes.userModel, adapterName: HiveAdapters.userModel)
class UserModel extends HiveObject {
  // @HiveField(UserModelFields.uid)
  String uid;

  // @HiveField(UserModelFields.phonenumber)
  String phonenumber;
  // @HiveField(UserModelFields.email)
  String email;
  // @HiveField(UserModelFields.profileIds)
  List<String> profileIds;

  // @HiveField(UserModelFields.fcmToken)
  String fcmToken;
  // @HiveField(UserModelFields.isOnline)
  bool isOnline;
  // @HiveField(UserModelFields.createdAt)
  DateTime createdAt;
  // @HiveField(UserModelFields.updatedAt)
  DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.phonenumber,
    required this.email,
    required this.profileIds,
    required this.fcmToken,
    required this.isOnline,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? uid,
    String? phonenumber,
    String? email,
    List<String>? profileIds,
    String? fcmToken,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phonenumber: phonenumber ?? this.phonenumber,
      email: email ?? this.email,
      profileIds: profileIds ?? this.profileIds,
      fcmToken: fcmToken ?? this.fcmToken,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'phonenumber': phonenumber,
      'email': email,
      'profileIds': profileIds,
      'fcmToken': fcmToken,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      phonenumber: map['phonenumber'] as String,
      email: map['email'] as String,
      profileIds: List<String>.from((map['profileIds'] as List<String>)),
      fcmToken: map['fcmToken'] as String,
      isOnline: map['isOnline'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid,  phonenumber: $phonenumber, email: $email, profileIds: $profileIds,  fcmToken: $fcmToken, isOnline: $isOnline)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.phonenumber == phonenumber &&
        other.email == email &&
        listEquals(other.profileIds, profileIds) &&
        other.fcmToken == fcmToken &&
        other.isOnline == isOnline &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        phonenumber.hashCode ^
        email.hashCode ^
        profileIds.hashCode ^
        fcmToken.hashCode ^
        isOnline.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
