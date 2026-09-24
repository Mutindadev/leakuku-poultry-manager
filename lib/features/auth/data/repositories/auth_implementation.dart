import 'package:firebase_auth/firebase_auth.dart';
import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/auth/data/data_sources/remote.dart';
import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImplementation implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImplementation({required this.remoteDataSource});

  @override
  ResultFuture<User> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  @override
  ResultFuture<void> signOut() {
    return remoteDataSource.signOut();
  }

  @override
  ResultFuture<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) {
    return remoteDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  @override
  ResultFuture<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  User? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  ResultFuture<void> sendPasswordResetEmail(String email) {
    return remoteDataSource.sendPasswordResetEmail(email);
  }

  // Implementation details...
}
