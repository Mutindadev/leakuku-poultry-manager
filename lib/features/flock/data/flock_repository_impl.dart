import 'package:dartz/dartz.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/domain/repositories/flock_repository.dart';
import 'package:leakuku/features/flock/data/flock_local_data_source.dart';
import 'package:leakuku/features/flock/domain/entities/flock.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';

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
      );
      await localDataSource.addFlock(flockModel);
      return Right(flock);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Flock>> getFlock(String flockId) async {
    try {
      final flockModel = await localDataSource.getFlockById(flockId);
      return Right(_toEntity(flockModel));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Flock>>> getAllFlocks(String userId) async {
    try {
      final flockModels = await localDataSource.getAllFlocks(userId);
      final flocks = flockModels.map((model) => _toEntity(model)).toList();
      return Right(flocks);
    } catch (e) {
      return Left(CacheFailure());
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
      );
      await localDataSource.updateFlock(flockModel);
      return Right(flock);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteFlock(String flockId) async {
    try {
      await localDataSource.deleteFlock(flockId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  Flock _toEntity(FlockModel model) {
    return Flock(
      id: model.id,
      name: model.name,
      breed: model.breed,
      quantity: model.quantity,
      purchaseDate: model.purchaseDate,
      notes: model.notes,
      userId: model.userId,
    );
  }
}
