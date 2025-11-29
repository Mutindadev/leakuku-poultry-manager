import 'package:hive/hive.dart';

part 'weekly_plan_model.g.dart';

@HiveType(typeId: 12)
class WeeklyPlanModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String flockId;

  @HiveField(2)
  int weekNumber;

  @HiveField(3)
  double plannedFeedGramsPerBird;

  @HiveField(4)
  double plannedTotalFeedKg;

  @HiveField(5)
  double plannedWaterLiters;

  @HiveField(6)
  double plannedBodyWeightKg;

  @HiveField(7)
  double plannedTemperatureCelsius;

  @HiveField(8)
  double plannedMortalityPercent;

  @HiveField(9)
  double? actualFeedGramsPerBird;

  @HiveField(10)
  double? actualTotalFeedKg;

  @HiveField(11)
  double? actualWaterLiters;

  @HiveField(12)
  double? actualBodyWeightKg;

  @HiveField(13)
  double? actualTemperatureCelsius;

  @HiveField(14)
  double? actualMortalityPercent;

  @HiveField(15)
  DateTime weekStartDate;

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
  });
}
