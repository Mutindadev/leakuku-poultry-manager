// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:leakuku/features/flock/data/models/flock_model.dart';

class Flock {
  final String id;
  final String name;
  final String breed;
  final int quantity;
  final DateTime purchaseDate;
  final String? notes;
  final String userId;
  // lifecycle

  final String status; // active, sold, archived, completed

  final DateTime createdAt;

  final DateTime updatedAt;

  final DateTime startedAt;

  final DateTime? expectedEndDate;

  // rship linking

  final List<String>? vaccineIds;

  final List<String>? weeklyPlanIds;

  final List<String>? dailyRecordsIds;

  final List<String>? stockItemIds;

  final List<String>? financeTransactionIds;

  final String currentWeek;

  final String mortalityPercent;

  final String avgBirdWeightKg;

  final String feedConsumedKg;

  final String waterConsumedLiters;

  final String lowStockItemsCount;

  final String pendingVaccinesCount;

  final String lastDailyRecordDate;

  const Flock({
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

  static Flock toEntity(FlockModel model) {
    return Flock(
      id: model.id,
      name: model.name,
      breed: model.breed,
      quantity: model.quantity,
      purchaseDate: model.purchaseDate,
      notes: model.notes,
      userId: model.userId,
      status: model.status,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      startedAt: model.startedAt,
      expectedEndDate: model.expectedEndDate,
      vaccineIds: model.vaccineIds,
      weeklyPlanIds: model.weeklyPlanIds,
      dailyRecordsIds: model.dailyRecordsIds,
      stockItemIds: model.stockItemIds,
      financeTransactionIds: model.financeTransactionIds,
      currentWeek: model.currentWeek,
      mortalityPercent: model.mortalityPercent,
      avgBirdWeightKg: model.avgBirdWeightKg,
      feedConsumedKg: model.feedConsumedKg,
      waterConsumedLiters: model.waterConsumedLiters,
      lowStockItemsCount: model.lowStockItemsCount,
      pendingVaccinesCount: model.pendingVaccinesCount,
      lastDailyRecordDate: model.lastDailyRecordDate,
    );
  }
}
