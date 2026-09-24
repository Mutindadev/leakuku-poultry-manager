import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/user/domain/repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase({required this.repository});

  ResultFuture<void> call(String uid) {
    return repository.deleteUser(uid);
  }
}
