import 'package:firebase_auth/firebase_auth.dart';
import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  final AuthRepository repository;

  RegisterWithEmailUseCase({required this.repository});

  ResultFuture<User> call(
    String email,
    String password,
    String fullName,
  ) async {
    return await repository.registerWithEmailAndPassword(
      password: password,
      fullName: fullName,
      email: email,
    );
  }
}
