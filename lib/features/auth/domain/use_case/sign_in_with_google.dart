import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase({required this.repository});

  ResultFuture<void> call() async {
    return await repository.signInWithGoogle();
  }
}
