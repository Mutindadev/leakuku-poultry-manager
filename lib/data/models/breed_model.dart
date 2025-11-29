import 'package:hive/hive.dart';

part 'breed_model.g.dart';

@HiveType(typeId: 10)
class BreedModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String purpose;

  @HiveField(3)
  List<String> keyBenefits;

  @HiveField(4)
  Map<dynamic, dynamic> weeklyExpectedWeight;

  @HiveField(5)
  Map<dynamic, dynamic> weeklyFeedGrams;

  @HiveField(6)
  int? expectedEggsPerYear;

  @HiveField(7)
  int cycleDurationDays;

  @HiveField(8)
  double defaultFeedGramsPerWeek;

  BreedModel({
    required this.id,
    required this.name,
    required this.purpose,
    required this.keyBenefits,
    required Map<int, double> weeklyExpectedWeight,
    required Map<int, double> weeklyFeedGrams,
    this.expectedEggsPerYear,
    required this.cycleDurationDays,
    required this.defaultFeedGramsPerWeek,
  }) : weeklyExpectedWeight = weeklyExpectedWeight,
       weeklyFeedGrams = weeklyFeedGrams;

  int get cycleDurationWeeks => (cycleDurationDays / 7).ceil();
  int get maturityDay => cycleDurationDays;
}
