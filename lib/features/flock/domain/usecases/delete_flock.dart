import 'package:dartz/dartz.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/domain/repositories/flock_repository.dart';

class DeleteFlock {
  final FlockRepository repository;

  DeleteFlock(this.repository);

  Future<Either<Failure, void>> call(String flockId) async {
    return await repository.deleteFlock(flockId);
  }
}
