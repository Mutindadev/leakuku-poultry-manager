import 'package:dartz/dartz.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/domain/repositories/flock_repository.dart';
import 'package:leakuku/features/flock/domain/entities/flock.dart';

class CreateFlock {
  final FlockRepository repository;

  CreateFlock(this.repository);

  Future<Either<Failure, Flock>> call(Flock flock) async {
    return await repository.createFlock(flock);
  }
}
