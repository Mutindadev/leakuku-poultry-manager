import 'package:hive/hive.dart';

part 'vaccine_model.g.dart';

@HiveType(typeId: 11)
class VaccineModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  int? dayOfCycle;

  @HiveField(2)
  String? weekRange;

  @HiveField(3)
  String vaccineName;

  @HiveField(4)
  String disease;

  @HiveField(5)
  String application;

  @HiveField(6)
  bool isOptional;

  @HiveField(7)
  String breedId;

  VaccineModel({
    required this.id,
    this.dayOfCycle,
    this.weekRange,
    required this.vaccineName,
    required this.disease,
    required this.application,
    this.isOptional = false,
    required this.breedId,
  });

  int get scheduleDayOffset {
    if (dayOfCycle != null) return dayOfCycle!;
    if (weekRange != null && weekRange!.contains('-')) {
      final weekStart = int.tryParse(weekRange!.split('-').first.replaceAll('Week ', '').trim()) ?? 1;
      return weekStart * 7;
    }
    return 1;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dayOfCycle': dayOfCycle,
        'weekRange': weekRange,
        'vaccineName': vaccineName,
        'disease': disease,
        'application': application,
        'isOptional': isOptional,
        'breedId': breedId,
      };

  factory VaccineModel.fromJson(Map<String, dynamic> json) => VaccineModel(
        id: json['id'] as String,
        dayOfCycle: json['dayOfCycle'] as int?,
        weekRange: json['weekRange'] as String?,
        vaccineName: json['vaccineName'] as String,
        disease: json['disease'] as String,
        application: json['application'] as String,
        isOptional: json['isOptional'] as bool? ?? false,
        breedId: json['breedId'] as String,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VaccineModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
