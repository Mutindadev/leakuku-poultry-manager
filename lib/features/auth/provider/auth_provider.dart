// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:leakuku/core/error/failures.dart';
// import 'package:leakuku/features/auth/data/data_sources/remote.dart';
// import 'package:leakuku/features/auth/data/data_sources/remote_implementation.dart';
// import 'package:leakuku/features/auth/data/repositories/auth_implementation.dart';
// import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';
// import 'package:leakuku/features/auth/domain/use_case/password_reset.dart';
// import 'package:leakuku/features/auth/domain/use_case/register_with_email.dart';
// import 'package:leakuku/features/auth/domain/use_case/sign_in_with_google.dart';
// import 'package:leakuku/features/auth/domain/use_case/sign_out.dart';
// import 'package:leakuku/features/auth/domain/use_case/signin_with_email.dart';

// final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
//   return AuthRemoteDataSourceImplementation();
// });

// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
//   return AuthRepositoryImplementation(remoteDataSource: remoteDataSource);
// });

// final signInWithEmailUseCaseProvider = Provider<SigninWithEmailUseCase>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return SigninWithEmailUseCase(repository: repository);
// });

// final registerWithEmailUseCaseProvider =
//     Provider<RegisterWithEmailUseCase>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return RegisterWithEmailUseCase(repository: repository);
// });

// final signInWithGoogleUseCaseProvider =
//     Provider<SignInWithGoogleUseCase>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return SignInWithGoogleUseCase(repository: repository);
// });

// final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return SignOutUseCase(repository: repository);
// });

// final passwordResetUseCaseProvider = Provider<PasswordResetUseCase>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return PasswordResetUseCase(repository: repository);
// });

// class AuthState {
//   final User? user;
//   final bool isLoading;
//   final Failure? error;

//   const AuthState({
//     this.user,
//     this.isLoading = false,
//     this.error,
//   });

//   AuthState copyWith({
//     User? user,
//     bool? isLoading,
//     Failure? error,
//   }) {
//     return AuthState(
//       user: user ?? this.user,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//     );
//   }
// }

// class AuthNotifier extends StateNotifier<AuthState> {
//   final SigninWithEmailUseCase _signInWithEmailUseCase;
//   final RegisterWithEmailUseCase _registerWithEmailUseCase;
//   final SignInWithGoogleUseCase _signInWithGoogleUseCase;
//   final SignOutUseCase _signOutUseCase;
//   final PasswordResetUseCase _passwordResetUseCase;

//   AuthNotifier({
//     required SigninWithEmailUseCase signInWithEmailUseCase,
//     required RegisterWithEmailUseCase registerWithEmailUseCase,
//     required SignInWithGoogleUseCase signInWithGoogleUseCase,
//     required SignOutUseCase signOutUseCase,
//     required PasswordResetUseCase passwordResetUseCase,
//   })  : _signInWithEmailUseCase = signInWithEmailUseCase,
//         _registerWithEmailUseCase = registerWithEmailUseCase,
//         _signInWithGoogleUseCase = signInWithGoogleUseCase,
//         _signOutUseCase = signOutUseCase,
//         _passwordResetUseCase = passwordResetUseCase,
//         super(const AuthState());

//   Future<User> signInWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await _signInWithEmailUseCase.call(email, password);

//     result.fold(
//       (failure) => state = state.copyWith(isLoading: false, error: failure),
//       (user) => state = state.copyWith(
//         isLoading: false,
//         error: null,
//         user: user,
//       ),
//     );
//   }

//   Future<void> registerWithEmail({
//     required String email,
//     required String password,
//     required String fullName,
//   }) async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await _registerWithEmailUseCase.call(
//       email,
//       password,
//       fullName,
//     );

//     result.fold(
//       (failure) => state = state.copyWith(isLoading: false, error: failure),
//       (user) => state = state.copyWith(
//         isLoading: false,
//         error: null,
//         // user: user,
//       ),
//     );
//   }

//   Future<void> signInWithGoogle() async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await _signInWithGoogleUseCase.call();

//     result.fold(
//       (failure) => state = state.copyWith(isLoading: false, error: failure),
//       (user) => state = state.copyWith(
//         isLoading: false,
//         error: null,
//         // user: user,
//       ),
//     );
//   }

//   Future<void> signOut() async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await _signOutUseCase.call();

//     result.fold(
//       (failure) => state = state.copyWith(isLoading: false, error: failure),
//       (_) => state = state.copyWith(
//         isLoading: false,
//         error: null,
//         user: null,
//       ),
//     );
//   }

//   Future<void> resetPassword(String email) async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await _passwordResetUseCase.call(email);

//     result.fold(
//       (failure) => state = state.copyWith(isLoading: false, error: failure),
//       (_) => state = state.copyWith(isLoading: false, error: null),
//     );
//   }

//   User? getCurrentUser() {
//     return state.user ?? FirebaseAuth.instance.currentUser;
//   }
// }

// final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
//   return AuthNotifier(
//     signInWithEmailUseCase: ref.watch(signInWithEmailUseCaseProvider),
//     registerWithEmailUseCase: ref.watch(registerWithEmailUseCaseProvider),
//     signInWithGoogleUseCase: ref.watch(signInWithGoogleUseCaseProvider),
//     signOutUseCase: ref.watch(signOutUseCaseProvider),
//     passwordResetUseCase: ref.watch(passwordResetUseCaseProvider),
//   );
// });
