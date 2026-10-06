import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase({required this.repository});

  ResultFuture<void> call() {
    return repository.signOut();
  }
}
