// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/hive_helper/fields/flock_model_fields.dart';
import 'package:leakuku/hive_helper/hive_adapters.dart';
import 'package:leakuku/hive_helper/hive_types.dart';

part 'flock_model.g.dart';

@HiveType(typeId: HiveTypes.flockModel, adapterName: HiveAdapters.flockModel)
class FlockModel extends HiveObject {
  @HiveField(FlockModelFields.id)
  final String id;

  @HiveField(FlockModelFields.name)
  final String name;

  @HiveField(FlockModelFields.breed)
  final String breed; // Layers, Broilers, Improved Kienyeji

  @HiveField(FlockModelFields.quantity)
  final int quantity;

  @HiveField(FlockModelFields.purchaseDate)
  final DateTime purchaseDate;

  @HiveField(FlockModelFields.notes)
  final String? notes;

  @HiveField(FlockModelFields.userId)
  final String userId; // Link to owner

  // lifecycle
  @HiveField(FlockModelFields.status)
  final String status; // active, sold, archived, completed
  @HiveField(FlockModelFields.createdAt)
  final DateTime createdAt;
  @HiveField(FlockModelFields.updatedAt)
  final DateTime updatedAt;
  @HiveField(FlockModelFields.startedAt)
  final DateTime startedAt;
  @HiveField(FlockModelFields.expectedEndDate)
  final DateTime? expectedEndDate;

  // rship linking
  @HiveField(FlockModelFields.vaccineIds)
  final List<String>? vaccineIds;
  @HiveField(FlockModelFields.weeklyPlanIds)
  final List<String>? weeklyPlanIds;
  @HiveField(FlockModelFields.dailyRecordsIds)
  final List<String>? dailyRecordsIds;
  @HiveField(FlockModelFields.stockItemIds)
  final List<String>? stockItemIds;
  @HiveField(FlockModelFields.financeTransactionIds)
  final List<String>? financeTransactionIds;

  @HiveField(FlockModelFields.currentWeek)
  final String currentWeek;
  @HiveField(FlockModelFields.mortalityPercent)
  final String mortalityPercent;
  @HiveField(FlockModelFields.avgBirdWeightKg)
  final String avgBirdWeightKg;
  @HiveField(FlockModelFields.feedConsumedKg)
  final String feedConsumedKg;
  @HiveField(FlockModelFields.waterConsumedLiters)
  final String waterConsumedLiters;
  @HiveField(FlockModelFields.lowStockItemsCount)
  final String lowStockItemsCount;
  @HiveField(FlockModelFields.pendingVaccinesCount)
  final String pendingVaccinesCount;
  @HiveField(FlockModelFields.lastDailyRecordDate)
  final String lastDailyRecordDate;

  FlockModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.quantity,
    required this.purchaseDate,
    this.notes,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.startedAt,
    this.expectedEndDate,
    this.vaccineIds,
    this.weeklyPlanIds,
    this.dailyRecordsIds,
    this.stockItemIds,
    this.financeTransactionIds,
    required this.currentWeek,
    required this.mortalityPercent,
    required this.avgBirdWeightKg,
    required this.feedConsumedKg,
    required this.waterConsumedLiters,
    required this.lowStockItemsCount,
    required this.pendingVaccinesCount,
    required this.lastDailyRecordDate,
  });

  FlockModel copyWith({
    String? id,
    String? name,
    String? breed,
    int? quantity,
    DateTime? purchaseDate,
    String? notes,
    String? userId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startedAt,
    DateTime? expectedEndDate,
    List<String>? vaccineIds,
    List<String>? weeklyPlanIds,
    List<String>? dailyRecordsIds,
    List<String>? stockItemIds,
    List<String>? financeTransactionIds,
    String? currentWeek,
    String? mortalityPercent,
    String? avgBirdWeightKg,
    String? feedConsumedKg,
    String? waterConsumedLiters,
    String? lowStockItemsCount,
    String? pendingVaccinesCount,
    String? lastDailyRecordDate,
  }) {
    return FlockModel(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      quantity: quantity ?? this.quantity,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      vaccineIds: vaccineIds ?? this.vaccineIds,
      weeklyPlanIds: weeklyPlanIds ?? this.weeklyPlanIds,
      dailyRecordsIds: dailyRecordsIds ?? this.dailyRecordsIds,
      stockItemIds: stockItemIds ?? this.stockItemIds,
      financeTransactionIds:
          financeTransactionIds ?? this.financeTransactionIds,
      currentWeek: currentWeek ?? this.currentWeek,
      mortalityPercent: mortalityPercent ?? this.mortalityPercent,
      avgBirdWeightKg: avgBirdWeightKg ?? this.avgBirdWeightKg,
      feedConsumedKg: feedConsumedKg ?? this.feedConsumedKg,
      waterConsumedLiters: waterConsumedLiters ?? this.waterConsumedLiters,
      lowStockItemsCount: lowStockItemsCount ?? this.lowStockItemsCount,
      pendingVaccinesCount: pendingVaccinesCount ?? this.pendingVaccinesCount,
      lastDailyRecordDate: lastDailyRecordDate ?? this.lastDailyRecordDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'breed': breed,
      'quantity': quantity,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'notes': notes,
      'userId': userId,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'expectedEndDate': expectedEndDate?.millisecondsSinceEpoch,
      'vaccineIds': vaccineIds,
      'weeklyPlanIds': weeklyPlanIds,
      'dailyRecordsIds': dailyRecordsIds,
      'stockItemIds': stockItemIds,
      'financeTransactionIds': financeTransactionIds,
      'currentWeek': currentWeek,
      'mortalityPercent': mortalityPercent,
      'avgBirdWeightKg': avgBirdWeightKg,
      'feedConsumedKg': feedConsumedKg,
      'waterConsumedLiters': waterConsumedLiters,
      'lowStockItemsCount': lowStockItemsCount,
      'pendingVaccinesCount': pendingVaccinesCount,
      'lastDailyRecordDate': lastDailyRecordDate,
    };
  }

  factory FlockModel.fromMap(Map<String, dynamic> map) {
    return FlockModel(
      id: map['id'] as String,
      name: map['name'] as String,
      breed: map['breed'] as String,
      quantity: map['quantity'] as int,
      purchaseDate:
          DateTime.fromMillisecondsSinceEpoch(map['purchaseDate'] as int),
      notes: map['notes'] != null ? map['notes'] as String : null,
      userId: map['userId'] as String,
      status: map['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['startedAt'] as int),
      expectedEndDate: map['expectedEndDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expectedEndDate'] as int)
          : null,
      vaccineIds: map['vaccineIds'] != null
          ? List<String>.from(map['vaccineIds'] as List)
          : null,
      weeklyPlanIds: map['weeklyPlanIds'] != null
          ? List<String>.from(map['weeklyPlanIds'] as List)
          : null,
      dailyRecordsIds: map['dailyRecordsIds'] != null
          ? List<String>.from(map['dailyRecordsIds'] as List)
          : null,
      stockItemIds: map['stockItemIds'] != null
          ? List<String>.from(map['stockItemIds'] as List)
          : null,
      financeTransactionIds: map['financeTransactionIds'] != null
          ? List<String>.from(map['financeTransactionIds'] as List)
          : null,
      currentWeek: map['currentWeek'] as String,
      mortalityPercent: map['mortalityPercent'] as String,
      avgBirdWeightKg: map['avgBirdWeightKg'] as String,
      feedConsumedKg: map['feedConsumedKg'] as String,
      waterConsumedLiters: map['waterConsumedLiters'] as String,
      lowStockItemsCount: map['lowStockItemsCount'] as String,
      pendingVaccinesCount: map['pendingVaccinesCount'] as String,
      lastDailyRecordDate: map['lastDailyRecordDate'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory FlockModel.fromJson(String source) =>
      FlockModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FlockModel(id: $id, name: $name, breed: $breed, quantity: $quantity, purchaseDate: $purchaseDate, notes: $notes, userId: $userId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, expectedEndDate: $expectedEndDate, vaccineIds: $vaccineIds, weeklyPlanIds: $weeklyPlanIds, dailyRecordsIds: $dailyRecordsIds, stockItemIds: $stockItemIds, financeTransactionIds: $financeTransactionIds, currentWeek: $currentWeek, mortalityPercent: $mortalityPercent, avgBirdWeightKg: $avgBirdWeightKg, feedConsumedKg: $feedConsumedKg, waterConsumedLiters: $waterConsumedLiters, lowStockItemsCount: $lowStockItemsCount, pendingVaccinesCount: $pendingVaccinesCount, lastDailyRecordDate: $lastDailyRecordDate)';
  }

  @override
  bool operator ==(covariant FlockModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.breed == breed &&
        other.quantity == quantity &&
        other.purchaseDate == purchaseDate &&
        other.notes == notes &&
        other.userId == userId &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.startedAt == startedAt &&
        other.expectedEndDate == expectedEndDate &&
        listEquals(other.vaccineIds, vaccineIds) &&
        listEquals(other.weeklyPlanIds, weeklyPlanIds) &&
        listEquals(other.dailyRecordsIds, dailyRecordsIds) &&
        listEquals(other.stockItemIds, stockItemIds) &&
        listEquals(other.financeTransactionIds, financeTransactionIds) &&
        other.currentWeek == currentWeek &&
        other.mortalityPercent == mortalityPercent &&
        other.avgBirdWeightKg == avgBirdWeightKg &&
        other.feedConsumedKg == feedConsumedKg &&
        other.waterConsumedLiters == waterConsumedLiters &&
        other.lowStockItemsCount == lowStockItemsCount &&
        other.pendingVaccinesCount == pendingVaccinesCount &&
        other.lastDailyRecordDate == lastDailyRecordDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        breed.hashCode ^
        quantity.hashCode ^
        purchaseDate.hashCode ^
        notes.hashCode ^
        userId.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        startedAt.hashCode ^
        expectedEndDate.hashCode ^
        vaccineIds.hashCode ^
        weeklyPlanIds.hashCode ^
        dailyRecordsIds.hashCode ^
        stockItemIds.hashCode ^
        financeTransactionIds.hashCode ^
        currentWeek.hashCode ^
        mortalityPercent.hashCode ^
        avgBirdWeightKg.hashCode ^
        feedConsumedKg.hashCode ^
        waterConsumedLiters.hashCode ^
        lowStockItemsCount.hashCode ^
        pendingVaccinesCount.hashCode ^
        lastDailyRecordDate.hashCode;
  }
}
