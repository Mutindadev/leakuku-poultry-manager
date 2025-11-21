import 'package:dartz/dartz.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/domain/repositories/flock_repository.dart';
import 'package:leakuku/features/flock/domain/entities/flock.dart';

class GetAllFlocks {
  final FlockRepository repository;

  GetAllFlocks(this.repository);

  Future<Either<Failure, List<Flock>>> call(String userId) async {
    return await repository.getAllFlocks(userId);
  }
}
