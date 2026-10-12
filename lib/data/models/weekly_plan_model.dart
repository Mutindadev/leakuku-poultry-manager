// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:leakuku/hive_helper/fields/weekly_plan_model_fields.dart';
import 'package:leakuku/hive_helper/hive_adapters.dart';
import 'package:leakuku/hive_helper/hive_types.dart';

part 'weekly_plan_model.g.dart';

@HiveType(
    typeId: HiveTypes.weeklyPlanModel,
    adapterName: HiveAdapters.weeklyPlanModel)
class WeeklyPlanModel extends HiveObject {
  @HiveField(WeeklyPlanModelFields.id)
  String id;

  @HiveField(WeeklyPlanModelFields.flockId)
  String flockId;

  @HiveField(WeeklyPlanModelFields.weekNumber)
  int weekNumber;

  @HiveField(WeeklyPlanModelFields.plannedFeedGramsPerBird)
  double plannedFeedGramsPerBird;

  @HiveField(WeeklyPlanModelFields.plannedTotalFeedKg)
  double plannedTotalFeedKg;

  @HiveField(WeeklyPlanModelFields.plannedWaterLiters)
  double plannedWaterLiters;

  @HiveField(WeeklyPlanModelFields.plannedBodyWeightKg)
  double plannedBodyWeightKg;

  @HiveField(WeeklyPlanModelFields.plannedTemperatureCelsius)
  double plannedTemperatureCelsius;

  @HiveField(WeeklyPlanModelFields.plannedMortalityPercent)
  double plannedMortalityPercent;

  @HiveField(WeeklyPlanModelFields.actualFeedGramsPerBird)
  double? actualFeedGramsPerBird;

  @HiveField(WeeklyPlanModelFields.actualTotalFeedKg)
  double? actualTotalFeedKg;

  @HiveField(WeeklyPlanModelFields.actualWaterLiters)
  double? actualWaterLiters;

  @HiveField(WeeklyPlanModelFields.actualBodyWeightKg)
  double? actualBodyWeightKg;

  @HiveField(WeeklyPlanModelFields.actualTemperatureCelsius)
  double? actualTemperatureCelsius;

  @HiveField(WeeklyPlanModelFields.actualMortalityPercent)
  double? actualMortalityPercent;

  @HiveField(WeeklyPlanModelFields.weekStartDate)
  DateTime weekStartDate;

  @HiveField(WeeklyPlanModelFields.updatedAt)
  DateTime updatedAt;

  WeeklyPlanModel({
    required this.id,
    required this.flockId,
    required this.weekNumber,
    required this.plannedFeedGramsPerBird,
    required this.plannedTotalFeedKg,
    required this.plannedWaterLiters,
    required this.plannedBodyWeightKg,
    required this.plannedTemperatureCelsius,
    required this.plannedMortalityPercent,
    this.actualFeedGramsPerBird,
    this.actualTotalFeedKg,
    this.actualWaterLiters,
    this.actualBodyWeightKg,
    this.actualTemperatureCelsius,
    this.actualMortalityPercent,
    required this.weekStartDate,
    required this.updatedAt,
  });

  WeeklyPlanModel copyWith({
    String? id,
    String? flockId,
    int? weekNumber,
    double? plannedFeedGramsPerBird,
    double? plannedTotalFeedKg,
    double? plannedWaterLiters,
    double? plannedBodyWeightKg,
    double? plannedTemperatureCelsius,
    double? plannedMortalityPercent,
    double? actualFeedGramsPerBird,
    double? actualTotalFeedKg,
    double? actualWaterLiters,
    double? actualBodyWeightKg,
    double? actualTemperatureCelsius,
    double? actualMortalityPercent,
    DateTime? weekStartDate,
    DateTime? updatedAt,
  }) {
    return WeeklyPlanModel(
      id: id ?? this.id,
      flockId: flockId ?? this.flockId,
      weekNumber: weekNumber ?? this.weekNumber,
      plannedFeedGramsPerBird:
          plannedFeedGramsPerBird ?? this.plannedFeedGramsPerBird,
      plannedTotalFeedKg: plannedTotalFeedKg ?? this.plannedTotalFeedKg,
      plannedWaterLiters: plannedWaterLiters ?? this.plannedWaterLiters,
      plannedBodyWeightKg: plannedBodyWeightKg ?? this.plannedBodyWeightKg,
      plannedTemperatureCelsius:
          plannedTemperatureCelsius ?? this.plannedTemperatureCelsius,
      plannedMortalityPercent:
          plannedMortalityPercent ?? this.plannedMortalityPercent,
      actualFeedGramsPerBird:
          actualFeedGramsPerBird ?? this.actualFeedGramsPerBird,
      actualTotalFeedKg: actualTotalFeedKg ?? this.actualTotalFeedKg,
      actualWaterLiters: actualWaterLiters ?? this.actualWaterLiters,
      actualBodyWeightKg: actualBodyWeightKg ?? this.actualBodyWeightKg,
      actualTemperatureCelsius:
          actualTemperatureCelsius ?? this.actualTemperatureCelsius,
      actualMortalityPercent:
          actualMortalityPercent ?? this.actualMortalityPercent,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'flockId': flockId,
      'weekNumber': weekNumber,
      'plannedFeedGramsPerBird': plannedFeedGramsPerBird,
      'plannedTotalFeedKg': plannedTotalFeedKg,
      'plannedWaterLiters': plannedWaterLiters,
      'plannedBodyWeightKg': plannedBodyWeightKg,
      'plannedTemperatureCelsius': plannedTemperatureCelsius,
      'plannedMortalityPercent': plannedMortalityPercent,
      'actualFeedGramsPerBird': actualFeedGramsPerBird,
      'actualTotalFeedKg': actualTotalFeedKg,
      'actualWaterLiters': actualWaterLiters,
      'actualBodyWeightKg': actualBodyWeightKg,
      'actualTemperatureCelsius': actualTemperatureCelsius,
      'actualMortalityPercent': actualMortalityPercent,
      'weekStartDate': weekStartDate.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory WeeklyPlanModel.fromMap(Map<String, dynamic> map) {
    return WeeklyPlanModel(
      id: map['id'] as String,
      flockId: map['flockId'] as String,
      weekNumber: map['weekNumber'] as int,
      plannedFeedGramsPerBird: map['plannedFeedGramsPerBird'] as double,
      plannedTotalFeedKg: map['plannedTotalFeedKg'] as double,
      plannedWaterLiters: map['plannedWaterLiters'] as double,
      plannedBodyWeightKg: map['plannedBodyWeightKg'] as double,
      plannedTemperatureCelsius: map['plannedTemperatureCelsius'] as double,
      plannedMortalityPercent: map['plannedMortalityPercent'] as double,
      actualFeedGramsPerBird: map['actualFeedGramsPerBird'] != null
          ? map['actualFeedGramsPerBird'] as double
          : null,
      actualTotalFeedKg: map['actualTotalFeedKg'] != null
          ? map['actualTotalFeedKg'] as double
          : null,
      actualWaterLiters: map['actualWaterLiters'] != null
          ? map['actualWaterLiters'] as double
          : null,
      actualBodyWeightKg: map['actualBodyWeightKg'] != null
          ? map['actualBodyWeightKg'] as double
          : null,
      actualTemperatureCelsius: map['actualTemperatureCelsius'] != null
          ? map['actualTemperatureCelsius'] as double
          : null,
      actualMortalityPercent: map['actualMortalityPercent'] != null
          ? map['actualMortalityPercent'] as double
          : null,
      weekStartDate:
          DateTime.fromMillisecondsSinceEpoch(map['weekStartDate'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory WeeklyPlanModel.fromJson(String source) =>
      WeeklyPlanModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WeeklyPlanModel(id: $id, flockId: $flockId, weekNumber: $weekNumber, plannedFeedGramsPerBird: $plannedFeedGramsPerBird, plannedTotalFeedKg: $plannedTotalFeedKg, plannedWaterLiters: $plannedWaterLiters, plannedBodyWeightKg: $plannedBodyWeightKg, plannedTemperatureCelsius: $plannedTemperatureCelsius, plannedMortalityPercent: $plannedMortalityPercent, actualFeedGramsPerBird: $actualFeedGramsPerBird, actualTotalFeedKg: $actualTotalFeedKg, actualWaterLiters: $actualWaterLiters, actualBodyWeightKg: $actualBodyWeightKg, actualTemperatureCelsius: $actualTemperatureCelsius, actualMortalityPercent: $actualMortalityPercent, weekStartDate: $weekStartDate, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant WeeklyPlanModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.flockId == flockId &&
        other.weekNumber == weekNumber &&
        other.plannedFeedGramsPerBird == plannedFeedGramsPerBird &&
        other.plannedTotalFeedKg == plannedTotalFeedKg &&
        other.plannedWaterLiters == plannedWaterLiters &&
        other.plannedBodyWeightKg == plannedBodyWeightKg &&
        other.plannedTemperatureCelsius == plannedTemperatureCelsius &&
        other.plannedMortalityPercent == plannedMortalityPercent &&
        other.actualFeedGramsPerBird == actualFeedGramsPerBird &&
        other.actualTotalFeedKg == actualTotalFeedKg &&
        other.actualWaterLiters == actualWaterLiters &&
        other.actualBodyWeightKg == actualBodyWeightKg &&
        other.actualTemperatureCelsius == actualTemperatureCelsius &&
        other.actualMortalityPercent == actualMortalityPercent &&
        other.weekStartDate == weekStartDate &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        flockId.hashCode ^
        weekNumber.hashCode ^
        plannedFeedGramsPerBird.hashCode ^
        plannedTotalFeedKg.hashCode ^
        plannedWaterLiters.hashCode ^
        plannedBodyWeightKg.hashCode ^
        plannedTemperatureCelsius.hashCode ^
        plannedMortalityPercent.hashCode ^
        actualFeedGramsPerBird.hashCode ^
        actualTotalFeedKg.hashCode ^
        actualWaterLiters.hashCode ^
        actualBodyWeightKg.hashCode ^
        actualTemperatureCelsius.hashCode ^
        actualMortalityPercent.hashCode ^
        weekStartDate.hashCode ^
        updatedAt.hashCode;
  }
}
