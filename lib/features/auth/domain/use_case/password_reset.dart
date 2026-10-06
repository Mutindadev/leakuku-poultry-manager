import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';

class PasswordResetUseCase {
  final AuthRepository repository;

  PasswordResetUseCase({required this.repository});

  ResultFuture<void> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}
