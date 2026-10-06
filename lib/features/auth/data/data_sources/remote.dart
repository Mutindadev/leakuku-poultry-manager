import 'package:firebase_auth/firebase_auth.dart';
import 'package:leakuku/core/utils/typedef.dart';

abstract class AuthRemoteDataSource {
  ResultFuture<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  ResultFuture<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  ResultFuture<void> sendPasswordResetEmail(String email);

  User? getCurrentUser();

  ResultFuture<User> signInWithGoogle();

  ResultFuture<void> signOut();
}
