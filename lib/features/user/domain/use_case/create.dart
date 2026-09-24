import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/user/data/models/user.dart';
import 'package:leakuku/features/user/domain/repositories/user_repository.dart';

class CreateUserUseCase {
  final UserRepository repository;

  CreateUserUseCase({required this.repository});

  ResultFuture<void> call(UserModel user) {
    return repository.createUser(user);
  }
}
