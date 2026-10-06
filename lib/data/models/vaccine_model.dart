// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:leakuku/hive_helper/fields/vaccine_model_fields.dart';
import 'package:leakuku/hive_helper/hive_adapters.dart';
import 'package:leakuku/hive_helper/hive_types.dart';

part 'vaccine_model.g.dart';

@HiveType(
    typeId: HiveTypes.vaccineModel, adapterName: HiveAdapters.vaccineModel)
class VaccineModel extends HiveObject {
  @HiveField(VaccineModelFields.id)
  String id;

  @HiveField(VaccineModelFields.dayOfCycle)
  int? dayOfCycle;

  @HiveField(VaccineModelFields.weekRange)
  String? weekRange;

  @HiveField(VaccineModelFields.vaccineName)
  String vaccineName;

  @HiveField(VaccineModelFields.disease)
  String disease;

  @HiveField(VaccineModelFields.application)
  String application;

  @HiveField(VaccineModelFields.isOptional)
  bool isOptional;

  @HiveField(VaccineModelFields.breedId)
  String breedId;
  @HiveField(VaccineModelFields.flockId)
  String? flockId;
  @HiveField(VaccineModelFields.status)
  String status; // scheduled, done, missed
  @HiveField(VaccineModelFields.completedAt)
  DateTime? completedAt;
  @HiveField(VaccineModelFields.createdAt)
  DateTime? createdAt;
  @HiveField(VaccineModelFields.updatedAt)
  DateTime? updatedAt;

  VaccineModel({
    required this.id,
    this.dayOfCycle,
    this.weekRange,
    required this.vaccineName,
    required this.disease,
    required this.application,
    this.isOptional = false,
    required this.breedId,
    this.flockId,
    this.status = 'scheduled',
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  int get scheduleDayOffset {
    if (dayOfCycle != null) return dayOfCycle!;
    if (weekRange != null && weekRange!.contains('-')) {
      final weekStart = int.tryParse(
              weekRange!.split('-').first.replaceAll('Week ', '').trim()) ??
          1;
      return weekStart * 7;
    }
    return 1;
  }

  VaccineModel copyWith({
    String? id,
    int? dayOfCycle,
    String? weekRange,
    String? vaccineName,
    String? disease,
    String? application,
    bool? isOptional,
    String? breedId,
    String? flockId,
    String? status,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaccineModel(
      id: id ?? this.id,
      dayOfCycle: dayOfCycle ?? this.dayOfCycle,
      weekRange: weekRange ?? this.weekRange,
      vaccineName: vaccineName ?? this.vaccineName,
      disease: disease ?? this.disease,
      application: application ?? this.application,
      isOptional: isOptional ?? this.isOptional,
      breedId: breedId ?? this.breedId,
      flockId: flockId ?? this.flockId,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'dayOfCycle': dayOfCycle,
      'weekRange': weekRange,
      'vaccineName': vaccineName,
      'disease': disease,
      'application': application,
      'isOptional': isOptional,
      'breedId': breedId,
      'flockId': flockId,
      'status': status,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory VaccineModel.fromMap(Map<String, dynamic> map) {
    return VaccineModel(
      id: map['id'] as String,
      dayOfCycle: map['dayOfCycle'] != null ? map['dayOfCycle'] as int : null,
      weekRange: map['weekRange'] != null ? map['weekRange'] as String : null,
      vaccineName: map['vaccineName'] as String,
      disease: map['disease'] as String,
      application: map['application'] as String,
      isOptional: map['isOptional'] as bool,
      breedId: map['breedId'] as String,
      flockId: map['flockId'] != null ? map['flockId'] as String : null,
      status: map['status'] as String,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory VaccineModel.fromJson(String source) =>
      VaccineModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'VaccineModel(id: $id, dayOfCycle: $dayOfCycle, weekRange: $weekRange, vaccineName: $vaccineName, disease: $disease, application: $application, isOptional: $isOptional, breedId: $breedId, flockId: $flockId, status: $status, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant VaccineModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.dayOfCycle == dayOfCycle &&
        other.weekRange == weekRange &&
        other.vaccineName == vaccineName &&
        other.disease == disease &&
        other.application == application &&
        other.isOptional == isOptional &&
        other.breedId == breedId &&
        other.flockId == flockId &&
        other.status == status &&
        other.completedAt == completedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        dayOfCycle.hashCode ^
        weekRange.hashCode ^
        vaccineName.hashCode ^
        disease.hashCode ^
        application.hashCode ^
        isOptional.hashCode ^
        breedId.hashCode ^
        flockId.hashCode ^
        status.hashCode ^
        completedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
