import 'package:firebase_auth/firebase_auth.dart';
import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';

class SigninWithEmailUseCase {
  final AuthRepository repository;

  SigninWithEmailUseCase({required this.repository});

  ResultFuture<User> call(String email, String password) async {
    return await repository.signInWithEmailAndPassword(
      password: password,
      email: email,
    );
  }
}
