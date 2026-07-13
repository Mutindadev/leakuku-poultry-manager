import 'package:hive/hive.dart';

part 'stock_item_model.g.dart';

@HiveType(typeId: 13)
class StockItemModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  String name;

  @HiveField(3)
  double quantity;

  @HiveField(4)
  String unit;

  @HiveField(5)
  double minimumLevel;

  @HiveField(6)
  DateTime lastUpdated;

  @HiveField(7)
  DateTime? expiryDate;

  @HiveField(8)
  String? supplier;

  @HiveField(9)
  double? cost;

  StockItemModel({
    required this.id,
    required this.category,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minimumLevel,
    required this.lastUpdated,
    this.expiryDate,
    this.supplier,
    this.cost,
  });

  bool get isLowStock => quantity <= minimumLevel;
}
