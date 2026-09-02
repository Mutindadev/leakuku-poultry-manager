import 'package:hive/hive.dart';

part 'financial_transaction_model.g.dart';

@HiveType(typeId: 15)
class FinancialTransactionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String transactionType;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final DateTime lastUpdated;

  @HiveField(8)
  final String? relatedFlock;

  @HiveField(9)
  final String? paymentMethod;

  const FinancialTransactionModel({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    required this.lastUpdated,
    this.relatedFlock,
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
    String? relatedFlock,
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
      relatedFlock: relatedFlock ?? this.relatedFlock,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
