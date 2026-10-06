import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/user/domain/repositories/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase({required this.repository});

  ResultFuture<void> call(DataMap updateData) {
    return repository.updateUser(updateData);
  }
}
