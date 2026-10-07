import 'package:dartz/dartz.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/domain/repositories/flock_repository.dart';
import 'package:leakuku/features/flock/data/data_sources/flock_local_data_source.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';
import 'package:leakuku/features/flock/domain/entities/flock.dart';

class FlockRepositoryImpl implements FlockRepository {
  final FlockLocalDataSource localDataSource;

  FlockRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Flock>> createFlock(Flock flock) async {
    try {
      final flockModel = FlockModel(
        id: flock.id,
        name: flock.name,
        breed: flock.breed,
        quantity: flock.quantity,
        purchaseDate: flock.purchaseDate,
        notes: flock.notes,
        userId: flock.userId,
        status: flock.status,
        createdAt: flock.createdAt,
        updatedAt: DateTime.now(),
        startedAt: flock.startedAt,
        expectedEndDate: flock.expectedEndDate,
        vaccineIds: flock.vaccineIds,
        weeklyPlanIds: flock.weeklyPlanIds,
        dailyRecordsIds: flock.dailyRecordsIds,
        stockItemIds: flock.stockItemIds,
        financeTransactionIds: flock.financeTransactionIds,
        currentWeek: flock.currentWeek,
        mortalityPercent: flock.mortalityPercent,
        avgBirdWeightKg: flock.avgBirdWeightKg,
        feedConsumedKg: flock.feedConsumedKg,
        waterConsumedLiters: flock.waterConsumedLiters,
        lowStockItemsCount: flock.lowStockItemsCount,
        pendingVaccinesCount: flock.pendingVaccinesCount,
        lastDailyRecordDate: flock.lastDailyRecordDate,
      );
      await localDataSource.addFlock(flockModel);
      return Right(flock);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to create flock', statusCode: 500));
    }
  }

  @override
  Future<Either<Failure, Flock>> getFlock(String flockId) async {
    try {
      final flockModel = await localDataSource.getFlockById(flockId);
      return Right(Flock.toEntity(flockModel));
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to get flock', statusCode: 500));
    }
  }

  @override
  Future<Either<Failure, List<Flock>>> getAllFlocks(String userId) async {
    try {
      final flockModels = await localDataSource.getAllFlocks(userId);
      final flocks = flockModels.map((model) => Flock.toEntity(model)).toList();
      return Right(flocks);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to get all flocks', statusCode: 500));
    }
  }

  @override
  Future<Either<Failure, Flock>> updateFlock(Flock flock) async {
    try {
      final flockModel = FlockModel(
        id: flock.id,
        name: flock.name,
        breed: flock.breed,
        quantity: flock.quantity,
        purchaseDate: flock.purchaseDate,
        notes: flock.notes,
        userId: flock.userId,
        status: flock.status,
        createdAt: flock.createdAt,
        updatedAt: DateTime.now(),
        startedAt: flock.startedAt,
        expectedEndDate: flock.expectedEndDate,
        vaccineIds: flock.vaccineIds,
        weeklyPlanIds: flock.weeklyPlanIds,
        dailyRecordsIds: flock.dailyRecordsIds,
        stockItemIds: flock.stockItemIds,
        financeTransactionIds: flock.financeTransactionIds,
        currentWeek: flock.currentWeek,
        mortalityPercent: flock.mortalityPercent,
        avgBirdWeightKg: flock.avgBirdWeightKg,
        feedConsumedKg: flock.feedConsumedKg,
        waterConsumedLiters: flock.waterConsumedLiters,
        lowStockItemsCount: flock.lowStockItemsCount,
        pendingVaccinesCount: flock.pendingVaccinesCount,
        lastDailyRecordDate: flock.lastDailyRecordDate,
      );
      await localDataSource.updateFlock(flockModel);
      return Right(flock);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to update flock', statusCode: 500));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFlock(String flockId) async {
    try {
      await localDataSource.deleteFlock(flockId);
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to delete flock', statusCode: 500));
    }
  }

}
