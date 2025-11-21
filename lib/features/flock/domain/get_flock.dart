import 'package:dartz/dartz.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/domain/repositories/flock_repository.dart';
import 'package:leakuku/features/flock/domain/entities/flock.dart';

class GetFlock {
  final FlockRepository repository;

  GetFlock(this.repository);

  Future<Either<Failure, Flock>> call(String flockId) async {
    return await repository.getFlock(flockId);
  }
}
