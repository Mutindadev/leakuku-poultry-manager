import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:leakuku/hive_helper/fields/financial_transaction_model_fields.dart';
import 'package:leakuku/hive_helper/hive_adapters.dart';
import 'package:leakuku/hive_helper/hive_types.dart';

part 'financial_transaction_model.g.dart';

@HiveType(
    typeId: HiveTypes.financialTransactionModel,
    adapterName: HiveAdapters.financialTransactionModel)
class FinancialTransactionModel extends HiveObject {
  @HiveField(FinancialTransactionModelFields.id)
  final String id;

  @HiveField(FinancialTransactionModelFields.userId)
  final String userId;

  @HiveField(FinancialTransactionModelFields.transactionType)
  final String transactionType;

  @HiveField(FinancialTransactionModelFields.category)
  final String category;

  @HiveField(FinancialTransactionModelFields.amount)
  final double amount;

  @HiveField(FinancialTransactionModelFields.date)
  final DateTime date;

  @HiveField(FinancialTransactionModelFields.notes)
  final String? notes;

  @HiveField(FinancialTransactionModelFields.lastUpdated)
  final DateTime lastUpdated;

  @HiveField(FinancialTransactionModelFields.flockId)
  final String flockId;

  @HiveField(FinancialTransactionModelFields.paymentMethod)
  final String? paymentMethod;

  FinancialTransactionModel({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    required this.lastUpdated,
    required this.flockId,
    this.paymentMethod,
  });

  bool get isIncome => transactionType == 'income';
  bool get isExpense => transactionType == 'expense';

  FinancialTransactionModel copyWith({
    String? id,
    String? userId,
    String? transactionType,
    String? category,
    double? amount,
    DateTime? date,
    String? notes,
    DateTime? lastUpdated,
    String? flockId,
    String? paymentMethod,
  }) {
    return FinancialTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      transactionType: transactionType ?? this.transactionType,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      flockId: flockId ?? this.flockId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'transactionType': transactionType,
      'category': category,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'flockId': flockId,
      'paymentMethod': paymentMethod,
    };
  }

  factory FinancialTransactionModel.fromMap(Map<String, dynamic> map) {
    return FinancialTransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      transactionType: map['transactionType'] as String,
      category: map['category'] as String,
      amount: map['amount'] as double,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      notes: map['notes'] != null ? map['notes'] as String : null,
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] as int),
      flockId: map['flockId'] as String,
      paymentMethod:
          map['paymentMethod'] != null ? map['paymentMethod'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FinancialTransactionModel.fromJson(String source) =>
      FinancialTransactionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FinancialTransactionModel(id: $id, userId: $userId, transactionType: $transactionType, category: $category, amount: $amount, date: $date, notes: $notes, lastUpdated: $lastUpdated, flockId: $flockId, paymentMethod: $paymentMethod)';
  }

  @override
  bool operator ==(covariant FinancialTransactionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.transactionType == transactionType &&
        other.category == category &&
        other.amount == amount &&
        other.date == date &&
        other.notes == notes &&
        other.lastUpdated == lastUpdated &&
        other.flockId == flockId &&
        other.paymentMethod == paymentMethod;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        transactionType.hashCode ^
        category.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        notes.hashCode ^
        lastUpdated.hashCode ^
        flockId.hashCode ^
        paymentMethod.hashCode;
  }
}
