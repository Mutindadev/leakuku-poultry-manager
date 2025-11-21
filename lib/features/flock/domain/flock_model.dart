import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'flock_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class FlockModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String breed; // Layers, Broilers, Improved Kienyeji

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final DateTime purchaseDate;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String userId; // Link to owner

  FlockModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.quantity,
    required this.purchaseDate,
    this.notes,
    required this.userId,
  });

  factory FlockModel.fromJson(Map<String, dynamic> json) => _$FlockModelFromJson(json);
  Map<String, dynamic> toJson() => _$FlockModelToJson(this);
}
