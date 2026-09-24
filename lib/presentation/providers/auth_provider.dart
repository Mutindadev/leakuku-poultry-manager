import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/core/services/session_service.dart';
import 'package:leakuku/data/models/user_model.dart';
import 'package:leakuku/domain/entities/user.dart';
import 'package:leakuku/features/auth/data/data_sources/remote_implementation.dart';
import 'package:leakuku/features/auth/data/repositories/auth_implementation.dart';
import 'package:leakuku/features/auth/domain/use_case/register_with_email.dart';
import 'package:leakuku/features/auth/domain/use_case/sign_out.dart';
import 'package:leakuku/features/auth/domain/use_case/signin_with_email.dart';

class AuthState {
  // final UserModel? userModel;
  final User? user;
  final String? error;
  final bool isLoading;
  // NEW: which action produced the last message and whether it's an input validation error
  final bool? lastWasRegister;
  final bool errorIsInput;

  AuthState({
    // this.userModel,
    this.user,
    this.error,
    this.isLoading = false,
    this.lastWasRegister,
    this.errorIsInput = false,
  });

  AuthState copyWith({
    User? user,
    String? error,
    bool? isLoading,
    bool? lastWasRegister,
    bool? errorIsInput,
  }) {
    return AuthState(
      user: user ?? this.user,
      // keep as-is: passing null explicitly clears the error, omitting the param also clears
      error: error,
      isLoading: isLoading ?? this.isLoading,
      lastWasRegister: lastWasRegister ?? this.lastWasRegister,
      errorIsInput: errorIsInput ?? this.errorIsInput,
    );
  }
}

SigninWithEmailUseCase _signInWithEmailUseCase = SigninWithEmailUseCase(
  repository: AuthRepositoryImplementation(
    remoteDataSource: AuthRemoteDataSourceImplementation(),
  ),
);

SignOutUseCase _signOutUseCase = SignOutUseCase(
  repository: AuthRepositoryImplementation(
    remoteDataSource: AuthRemoteDataSourceImplementation(),
  ),
);

RegisterWithEmailUseCase _registerWithEmailUseCase = RegisterWithEmailUseCase(
  repository: AuthRepositoryImplementation(
    remoteDataSource: AuthRemoteDataSourceImplementation(),
  ),
);

// ReadUserUseCase _readUserUseCase = ReadUserUseCase(
//   repository: UserRepositoryImplementation(
//     remoteDataSource: UserRemoteDataSourseImlementation(),
//   ),
// );

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final SessionService _sessionService = SessionService();
  AuthNotifier(this.ref) : super(AuthState()) {
    Future.microtask(() => checkSession());
  }

  Future<void> login(String email, String password) async {
    final e = email.trim();
    final p = password.trim();

    if (e.isEmpty || p.isEmpty) {
      state = state.copyWith(
        error: 'Please enter email and password',
        isLoading: false,
        lastWasRegister: false,
        errorIsInput: true,
      );
      return;
    }

    state = state.copyWith(
        isLoading: true,
        error: null,
        lastWasRegister: false,
        errorIsInput: false);
    try {
      // final loginUseCase = ref.read(authProvider);
      // final result = await loginUseCase.signInWithEmail(email: e, password: p);
      final result = await _signInWithEmailUseCase(e, p);
      result.fold(
        (failure) => state = state.copyWith(
          error: failure.message,
          isLoading: false,
          lastWasRegister: false,
          errorIsInput: false,
        ),
        (user) async {
          await _sessionService.saveSession(
            userId: user.uid,
            email: user.email ?? '',
          );
          state = state.copyWith(
            user: User(
              id: user.uid,
              name: user.displayName ?? '',
              email: user.email ?? '',
              role: 'farmer',
            ),
            isLoading: false,
            error: null,
            lastWasRegister: false,
            errorIsInput: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        lastWasRegister: false,
        errorIsInput: false,
      );
    }
  }

  Future<void> register(
      String name, String email, String password, String role) async {
    final n = name.trim();
    final e = email.trim();
    final p = password.trim();

    if (n.isEmpty || e.isEmpty || p.isEmpty) {
      state = state.copyWith(
        error: 'Please fill all fields',
        isLoading: false,
        lastWasRegister: true,
        errorIsInput: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      lastWasRegister: true,
      errorIsInput: false,
    );

    try {
      final result = await _registerWithEmailUseCase(e, p, name);
      result.fold(
        (failure) => state = state.copyWith(
          error: failure.message,
          isLoading: false,
          lastWasRegister: true,
          errorIsInput: false,
        ),
        (user) async {
          // await _sessionService.saveSession(
          //   userId: user.uid,
          //   email: user.email,
          // );
          state = state.copyWith(
            // user: user,
            isLoading: false,
            error: null,
            lastWasRegister: true,
            errorIsInput: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        lastWasRegister: true,
        errorIsInput: false,
      );
    }
  }

  Future<void> checkSession() async {
    final isLoggedIn = await _sessionService.isLoggedIn();
    if (!isLoggedIn) {
      state = state.copyWith(isLoading: false);
      return;
    }
    final data = await _sessionService.getSession();
    final userId = data['userId'];
    if (userId != null && userId.isNotEmpty) {
      try {
        final box = Hive.box<UserModel>('userBox');
        final model = box.values.firstWhere(
          (u) => u.id == userId,
          orElse: () => UserModel(
              id: userId,
              name: 'Farmer',
              email: data['email'] ?? '',
              role: 'Farmer'),
        );
        final restored = User(
            id: model.id,
            name: model.name,
            email: model.email,
            role: model.role);
        state = state.copyWith(user: restored, isLoading: false, error: null);
      } catch (_) {
        state = state.copyWith(isLoading: false);
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    final result = await _signOutUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(
          error: failure.message,
          isLoading: false,
        );
      },
      (_) async {
        await _sessionService.clearSession();
        state = AuthState();
      },
    );
  }
}

final authhProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
