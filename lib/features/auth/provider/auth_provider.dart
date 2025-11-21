import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/core/di.dart';
import 'package:leakuku/domain/entities/user.dart';
import 'package:leakuku/features/auth/domain/usecases/login_user.dart';
import 'package:leakuku/features/auth/domain/usecases/register_user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final Failure? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    User? user,
    bool? isLoading,
    Failure? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;

  AuthNotifier(this._loginUser, this._registerUser) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final params = LoginParams(email: email, password: password);
    final result = await _loginUser(params);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<void> register(String name, String email, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    final params = RegisterParams(name: name, email: email, password: password, role: role);
    final result = await _registerUser(params);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(loginUserProvider),
    ref.watch(registerUserProvider),
  );
});
