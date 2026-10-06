// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:leakuku/hive_helper/fields/stock_history_model_fields.dart';
import 'package:leakuku/hive_helper/hive_adapters.dart';
import 'package:leakuku/hive_helper/hive_types.dart';

part 'stock_history_model.g.dart';

@HiveType(
    typeId: HiveTypes.stockHistoryModel,
    adapterName: HiveAdapters.stockHistoryModel)
class StockHistoryModel extends HiveObject {
  @HiveField(StockHistoryModelFields.id)
  String id;

  @HiveField(StockHistoryModelFields.itemId)
  String itemId;

  @HiveField(StockHistoryModelFields.category)
  String category;

  @HiveField(StockHistoryModelFields.itemName)
  String itemName;

  @HiveField(StockHistoryModelFields.action)
  String action;

  @HiveField(StockHistoryModelFields.quantity)
  double quantity;

  @HiveField(StockHistoryModelFields.unit)
  String unit;

  @HiveField(StockHistoryModelFields.date)
  DateTime date;

  @HiveField(StockHistoryModelFields.balanceAfter)
  double balanceAfter;

  @HiveField(StockHistoryModelFields.notes)
  String? notes;

  @HiveField(StockHistoryModelFields.userId)
  String userId;

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
    this.userId = '',
  });

  StockHistoryModel copyWith({
    String? id,
    String? itemId,
    String? category,
    String? itemName,
    String? action,
    double? quantity,
    String? unit,
    DateTime? date,
    double? balanceAfter,
    String? notes,
    String? userId,
  }) {
    return StockHistoryModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      category: category ?? this.category,
      itemName: itemName ?? this.itemName,
      action: action ?? this.action,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'itemId': itemId,
      'category': category,
      'itemName': itemName,
      'action': action,
      'quantity': quantity,
      'unit': unit,
      'date': date.millisecondsSinceEpoch,
      'balanceAfter': balanceAfter,
      'notes': notes,
      'userId': userId,
    };
  }

  factory StockHistoryModel.fromMap(Map<String, dynamic> map) {
    return StockHistoryModel(
      id: map['id'] as String,
      itemId: map['itemId'] as String,
      category: map['category'] as String,
      itemName: map['itemName'] as String,
      action: map['action'] as String,
      quantity: map['quantity'] as double,
      unit: map['unit'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      balanceAfter: map['balanceAfter'] as double,
      notes: map['notes'] != null ? map['notes'] as String : null,
      userId: map['userId'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StockHistoryModel.fromJson(String source) =>
      StockHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StockHistoryModel(id: $id, itemId: $itemId, category: $category, itemName: $itemName, action: $action, quantity: $quantity, unit: $unit, date: $date, balanceAfter: $balanceAfter, notes: $notes, userId: $userId)';
  }

  @override
  bool operator ==(covariant StockHistoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.itemId == itemId &&
        other.category == category &&
        other.itemName == itemName &&
        other.action == action &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.date == date &&
        other.balanceAfter == balanceAfter &&
        other.notes == notes &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        itemId.hashCode ^
        category.hashCode ^
        itemName.hashCode ^
        action.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        date.hashCode ^
        balanceAfter.hashCode ^
        notes.hashCode ^
        userId.hashCode;
  }
}
