import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:leakuku/hive_helper/fields/stock_item_model_fields.dart';
import 'package:leakuku/hive_helper/hive_adapters.dart';
import 'package:leakuku/hive_helper/hive_types.dart';

part 'stock_item_model.g.dart';

@HiveType(
    typeId: HiveTypes.stockItemModel, adapterName: HiveAdapters.stockItemModel)
class StockItemModel extends HiveObject {
  @HiveField(StockItemModelFields.id)
  String id;

  @HiveField(StockItemModelFields.category)
  String category;

  @HiveField(StockItemModelFields.name)
  String name;

  @HiveField(StockItemModelFields.quantity)
  double quantity;

  @HiveField(StockItemModelFields.unit)
  String unit;

  @HiveField(StockItemModelFields.minimumLevel)
  double minimumLevel;

  @HiveField(StockItemModelFields.lastUpdated)
  DateTime lastUpdated;

  @HiveField(StockItemModelFields.expiryDate)
  DateTime? expiryDate;

  @HiveField(StockItemModelFields.supplier)
  String? supplier;

  @HiveField(StockItemModelFields.cost)
  double? cost;

  @HiveField(StockItemModelFields.userId)
  String userId;

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
    this.userId = '',
  });

  bool get isLowStock => quantity <= minimumLevel;

  StockItemModel copyWith({
    String? id,
    String? category,
    String? name,
    double? quantity,
    String? unit,
    double? minimumLevel,
    DateTime? lastUpdated,
    DateTime? expiryDate,
    String? supplier,
    double? cost,
    String? userId,
  }) {
    return StockItemModel(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minimumLevel: minimumLevel ?? this.minimumLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      expiryDate: expiryDate ?? this.expiryDate,
      supplier: supplier ?? this.supplier,
      cost: cost ?? this.cost,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'minimumLevel': minimumLevel,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'supplier': supplier,
      'cost': cost,
      'userId': userId,
    };
  }

  factory StockItemModel.fromMap(Map<String, dynamic> map) {
    return StockItemModel(
      id: map['id'] as String,
      category: map['category'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as double,
      unit: map['unit'] as String,
      minimumLevel: map['minimumLevel'] as double,
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] as int),
      expiryDate: map['expiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'] as int)
          : null,
      supplier: map['supplier'] != null ? map['supplier'] as String : null,
      cost: map['cost'] != null ? map['cost'] as double : null,
      userId: map['userId'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StockItemModel.fromJson(String source) =>
      StockItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StockItemModel(id: $id, category: $category, name: $name, quantity: $quantity, unit: $unit, minimumLevel: $minimumLevel, lastUpdated: $lastUpdated, expiryDate: $expiryDate, supplier: $supplier, cost: $cost, userId: $userId)';
  }

  @override
  bool operator ==(covariant StockItemModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.category == category &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.minimumLevel == minimumLevel &&
        other.lastUpdated == lastUpdated &&
        other.expiryDate == expiryDate &&
        other.supplier == supplier &&
        other.cost == cost &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        category.hashCode ^
        name.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        minimumLevel.hashCode ^
        lastUpdated.hashCode ^
        expiryDate.hashCode ^
        supplier.hashCode ^
        cost.hashCode ^
        userId.hashCode;
  }
}
