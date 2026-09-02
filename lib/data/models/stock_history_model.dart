import 'package:hive/hive.dart';

part 'stock_history_model.g.dart';

@HiveType(typeId: 14)
class StockHistoryModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String itemId;

  @HiveField(2)
  String category;

  @HiveField(3)
  String itemName;

  @HiveField(4)
  String action;

  @HiveField(5)
  double quantity;

  @HiveField(6)
  String unit;

  @HiveField(7)
  DateTime date;

  @HiveField(8)
  double balanceAfter;

  @HiveField(9)
  String? notes;

  StockHistoryModel({
    required this.id,
    required this.itemId,
    required this.category,
    required this.itemName,
    required this.action,
    required this.quantity,
    required this.unit,
    required this.date,
    required this.balanceAfter,
    this.notes,
  });
}
