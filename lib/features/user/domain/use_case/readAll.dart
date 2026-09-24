import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/user/domain/repositories/user_repository.dart';

class ReadAllUsersUseCase {
  final UserRepository repository;

  ReadAllUsersUseCase({required this.repository});

  ResultFuture<void> call() {
    return repository.readAllUsers();
  }
}
