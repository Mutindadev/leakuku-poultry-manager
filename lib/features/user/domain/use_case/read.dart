import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/user/data/models/user.dart';
import 'package:leakuku/features/user/domain/repositories/user_repository.dart';

class ReadUserUseCase {
  final UserRepository repository;

  ReadUserUseCase({required this.repository});

  ResultFuture<UserModel> call(String uid) {
    return repository.readUser(uid);
  }
}
