// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/hive_helper/fields/breed_model_fields.dart';
import 'package:leakuku/hive_helper/hive_adapters.dart';
import 'package:leakuku/hive_helper/hive_types.dart';

part 'breed_model.g.dart';

@HiveType(typeId: HiveTypes.breedModel, adapterName: HiveAdapters.breedModel)
class BreedModel extends HiveObject {
  @HiveField(BreedModelFields.id)
  String id;

  @HiveField(BreedModelFields.name)
  String name;

  @HiveField(BreedModelFields.purpose)
  String purpose;

  @HiveField(BreedModelFields.keyBenefits)
  List<String> keyBenefits;

  @HiveField(BreedModelFields.weeklyExpectedWeight)
  Map<dynamic, dynamic> weeklyExpectedWeight;

  @HiveField(BreedModelFields.weeklyFeedGrams)
  Map<dynamic, dynamic> weeklyFeedGrams;

  @HiveField(BreedModelFields.expectedEggsPerYear)
  int? expectedEggsPerYear;

  @HiveField(BreedModelFields.cycleDurationDays)
  int cycleDurationDays;

  @HiveField(BreedModelFields.defaultFeedGramsPerWeek)
  double defaultFeedGramsPerWeek;

  BreedModel({
    required this.id,
    required this.name,
    required this.purpose,
    required this.keyBenefits,
    required this.weeklyExpectedWeight,
    required this.weeklyFeedGrams,
    this.expectedEggsPerYear,
    required this.cycleDurationDays,
    required this.defaultFeedGramsPerWeek,
  });

  int get cycleDurationWeeks => (cycleDurationDays / 7).ceil();
  int get maturityDay => cycleDurationDays;

  BreedModel copyWith({
    String? id,
    String? name,
    String? purpose,
    List<String>? keyBenefits,
    Map<dynamic, dynamic>? weeklyExpectedWeight,
    Map<dynamic, dynamic>? weeklyFeedGrams,
    int? expectedEggsPerYear,
    int? cycleDurationDays,
    double? defaultFeedGramsPerWeek,
  }) {
    return BreedModel(
      id: id ?? this.id,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      keyBenefits: keyBenefits ?? this.keyBenefits,
      weeklyExpectedWeight: weeklyExpectedWeight ?? this.weeklyExpectedWeight,
      weeklyFeedGrams: weeklyFeedGrams ?? this.weeklyFeedGrams,
      expectedEggsPerYear: expectedEggsPerYear ?? this.expectedEggsPerYear,
      cycleDurationDays: cycleDurationDays ?? this.cycleDurationDays,
      defaultFeedGramsPerWeek:
          defaultFeedGramsPerWeek ?? this.defaultFeedGramsPerWeek,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'purpose': purpose,
      'keyBenefits': keyBenefits,
      'weeklyExpectedWeight': weeklyExpectedWeight,
      'weeklyFeedGrams': weeklyFeedGrams,
      'expectedEggsPerYear': expectedEggsPerYear,
      'cycleDurationDays': cycleDurationDays,
      'defaultFeedGramsPerWeek': defaultFeedGramsPerWeek,
    };
  }

  factory BreedModel.fromMap(Map<String, dynamic> map) {
    return BreedModel(
      id: map['id'] as String,
      name: map['name'] as String,
      purpose: map['purpose'] as String,
      keyBenefits: List<String>.from((map['keyBenefits'] as List<String>)),
      weeklyExpectedWeight: Map<dynamic, dynamic>.from(
          (map['weeklyExpectedWeight'] as Map<dynamic, dynamic>)),
      weeklyFeedGrams: Map<dynamic, dynamic>.from(
          (map['weeklyFeedGrams'] as Map<dynamic, dynamic>)),
      expectedEggsPerYear: map['expectedEggsPerYear'] != null
          ? map['expectedEggsPerYear'] as int
          : null,
      cycleDurationDays: map['cycleDurationDays'] as int,
      defaultFeedGramsPerWeek: map['defaultFeedGramsPerWeek'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory BreedModel.fromJson(String source) =>
      BreedModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BreedModel(id: $id, name: $name, purpose: $purpose, keyBenefits: $keyBenefits, weeklyExpectedWeight: $weeklyExpectedWeight, weeklyFeedGrams: $weeklyFeedGrams, expectedEggsPerYear: $expectedEggsPerYear, cycleDurationDays: $cycleDurationDays, defaultFeedGramsPerWeek: $defaultFeedGramsPerWeek)';
  }

  @override
  bool operator ==(covariant BreedModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.purpose == purpose &&
        listEquals(other.keyBenefits, keyBenefits) &&
        mapEquals(other.weeklyExpectedWeight, weeklyExpectedWeight) &&
        mapEquals(other.weeklyFeedGrams, weeklyFeedGrams) &&
        other.expectedEggsPerYear == expectedEggsPerYear &&
        other.cycleDurationDays == cycleDurationDays &&
        other.defaultFeedGramsPerWeek == defaultFeedGramsPerWeek;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        purpose.hashCode ^
        keyBenefits.hashCode ^
        weeklyExpectedWeight.hashCode ^
        weeklyFeedGrams.hashCode ^
        expectedEggsPerYear.hashCode ^
        cycleDurationDays.hashCode ^
        defaultFeedGramsPerWeek.hashCode;
  }
}
