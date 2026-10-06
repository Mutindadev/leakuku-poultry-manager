import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/auth/data/data_sources/remote.dart';

class AuthRemoteDataSourceImplementation implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  ResultFuture<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      if (result.user == null) {
        return Left(
          ServerFailure(
            message: 'Sign in failed - no user returned',
            statusCode: 500,
          ),
        );
      }

      return Right(result.user!);
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      return Left(ServerFailure(message: message, statusCode: e.hashCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred: ${e.toString()}',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  ResultFuture<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user == null) {
        return Left(
          ServerFailure(
            message: 'Registration failed - no user returned',
            statusCode: 500,
          ),
        );
      }

      // Update the user's display name
      await result.user!.updateDisplayName(fullName);
      await result.user!.reload();

      return Right(result.user!);
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      return Left(ServerFailure(message: message, statusCode: e.hashCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred: ${e.toString()}',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  ResultFuture<User> signInWithGoogle() async {
    try {
      // Sign out from previous Google session to ensure account picker shows
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) {
        return Left(
          ServerFailure(
            message: 'Google sign in was cancelled',
            statusCode: 500,
          ),
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential result = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (result.user == null) {
        return Left(
          ServerFailure(
            message: 'Google sign in failed - no user returned',
            statusCode: 500,
          ),
        );
      }

      return Right(result.user!);
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      return Left(ServerFailure(message: message, statusCode: e.hashCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Google sign in failed: ${e.toString()}',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  ResultFuture<void> signOut() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();

      await _googleSignIn.signOut();

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Sign out failed: ${e.toString()}',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  ResultFuture<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      return Left(ServerFailure(message: message, statusCode: e.hashCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to send password reset email: ${e.toString()}',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Helper method to convert Firebase Auth error codes to user-friendly messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
