import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/features/auth/data/data_sources/remote_implementation.dart';
import 'package:leakuku/features/auth/data/repositories/auth_implementation.dart';
import 'package:leakuku/features/auth/domain/use_case/password_reset.dart';
import 'package:leakuku/features/auth/domain/use_case/register_with_email.dart';
import 'package:leakuku/features/auth/domain/use_case/sign_out.dart';
import 'package:leakuku/features/auth/domain/use_case/signin_with_email.dart';
import 'package:leakuku/features/user/data/data_sources/remote_implementation.dart';
import 'package:leakuku/features/user/data/models/user.dart';
import 'package:leakuku/features/user/data/repositories/user_implementation.dart';
import 'package:leakuku/features/user/domain/use_case/create.dart';
import 'package:leakuku/features/user/domain/use_case/read.dart';
import 'package:leakuku/features/user/domain/use_case/update.dart';

enum AuthenticationState { unknown, authenticated, unauthenticated }

enum RegistrationState { unknown, incomplete, complete }

class UserState {
  final User? firebaseUser;
  final UserModel? userModel;
  final AuthenticationState authState;
  final bool isLoading;
  final String? errorMessage;

  const UserState({
    this.firebaseUser,
    this.userModel,
    this.authState = AuthenticationState.unknown,
    this.isLoading = false,
    this.errorMessage,
  });

  UserState copyWith({
    User? firebaseUser,
    UserModel? userModel,
    AuthenticationState? authState,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userModel: userModel ?? this.userModel,
      authState: authState ?? this.authState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  static const String _userBoxName = 'userBox';
  static const String _currentUserKey = 'current_user';

  final Ref ref;
  final SignOutUseCase _signOutUseCase = SignOutUseCase(
    repository: AuthRepositoryImplementation(
      remoteDataSource: AuthRemoteDataSourceImplementation(),
    ),
  );

  final ReadUserUseCase _readUserUseCase = ReadUserUseCase(
    repository: UserRepositoryImplementation(
      remoteDataSource: UserRemoteDataSourseImlementation(),
    ),
  );

  final SigninWithEmailUseCase _signinWithEmailUseCase = SigninWithEmailUseCase(
    repository: AuthRepositoryImplementation(
      remoteDataSource: AuthRemoteDataSourceImplementation(),
    ),
  );

  final RegisterWithEmailUseCase _registerWithEmailUseCase =
      RegisterWithEmailUseCase(
    repository: AuthRepositoryImplementation(
      remoteDataSource: AuthRemoteDataSourceImplementation(),
    ),
  );

  final PasswordResetUseCase _passwordResetUseCase = PasswordResetUseCase(
    repository: AuthRepositoryImplementation(
      remoteDataSource: AuthRemoteDataSourceImplementation(),
    ),
  );

  final CreateUserUseCase _createUserUseCase = CreateUserUseCase(
    repository: UserRepositoryImplementation(
      remoteDataSource: UserRemoteDataSourseImlementation(),
    ),
  );

  final UpdateUserUseCase _updateUserUseCase = UpdateUserUseCase(
    repository: UserRepositoryImplementation(
      remoteDataSource: UserRemoteDataSourseImlementation(),
    ),
  );

  Box<UserModel>? _userBox;
  StreamSubscription<User?>? _authSubscription;

  UserNotifier(this.ref) : super(const UserState()) {
    Future.microtask(_initializeHive);
    _listenToAuthChanges();
  }

  Future<void> _initializeHive() async {
    try {
      _userBox = await Hive.openBox<UserModel>(_userBoxName);
      final cachedUser = _userBox?.get(_currentUserKey);

      if (cachedUser != null) {
        state = state.copyWith(
          userModel: cachedUser,
          authState: AuthenticationState.authenticated,
        );
      }
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  Future<void> _cacheUserData(UserModel user) async {
    try {
      await _userBox?.put(_currentUserKey, user);
    } catch (e) {
      debugPrint('Error caching user data: $e');
    }
  }

  Future<void> _clearCachedUserData() async {
    try {
      await _userBox?.delete(_currentUserKey);
    } catch (e) {
      debugPrint('Error clearing cached user data: $e');
    }
  }

  void _listenToAuthChanges() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _handleSignOut();
      } else {
        // handleSignIn(user);
      }
    });
  }

  // Future<void> handleSignIn(User user) async {
  Future<void> handleSignIn(
    String email,
    String password,
    String? fcmToken,
  ) async {
    state = state.copyWith(isLoading: true);

    // final cachedUser = _userBox?.get(_currentUserKey);
    // if (cachedUser != null && cachedUser.uid == user.uid) {
    //   state = state.copyWith(userModel: cachedUser);
    //   await _refreshUserDataInBackground(user.uid);
    //   return;
    // }
    final result = await _signinWithEmailUseCase(
      email,
      password,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          authState: AuthenticationState.unauthenticated,
          isLoading: false,
        );
      },
      (user) async {
        try {
          final result = await _readUserUseCase(user.uid);

          result.fold(
            (failure) {
              state = state.copyWith(
                errorMessage: failure.message,
                authState: AuthenticationState.unauthenticated,
                isLoading: false,
              );
            },
            (userModel) async {
              state = state.copyWith(
                userModel: userModel.copyWith(fcmToken: fcmToken),
                firebaseUser: user,
                authState: AuthenticationState.authenticated,
                errorMessage: null,
                isLoading: false,
              );

              await _cacheUserData(userModel);

              await _updateUserUseCase(
                userModel.copyWith(fcmToken: fcmToken).toMap(),
              );
            },
          );
        } catch (e) {
          state = state.copyWith(
            errorMessage: 'Error fetching user data: $e',
            authState: AuthenticationState.unauthenticated,
            isLoading: false,
          );
        }

        state = state.copyWith(
          errorMessage: null,
          isLoading: false,
        );
      },
    );
  }

  Future<void> handleRegister(
    String email,
    String password,
    String name,
    String? fcmToken,
  ) async {
    state = state.copyWith(isLoading: true);

    final result = await _registerWithEmailUseCase(email, password, name);

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          authState: AuthenticationState.unauthenticated,
          isLoading: false,
        );
      },
      (user) async {
        try {
          final userModel = UserModel(
            uid: user.uid,
            name: name,
            email: user.email ?? '',
            role: 'farmer',
            phonenumber: '',
            flockIds: [],
            activeFlocks: [],
            fcmToken: fcmToken ?? '',
            isOnline: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastSyncedAt: DateTime.now(),
            lastLocalModifiedAt: DateTime.now(),
          );

          final createResult = await _createUserUseCase(userModel);

          createResult.fold(
            (failure) {
              state = state.copyWith(
                errorMessage: failure.message,
                authState: AuthenticationState.unauthenticated,
                isLoading: false,
              );
            },
            (_) async {
              state = state.copyWith(
                userModel: userModel,
                firebaseUser: user,
                authState: AuthenticationState.authenticated,
                errorMessage: null,
                isLoading: false,
              );
              await _cacheUserData(userModel);
            },
          );
        } catch (e) {
          state = state.copyWith(
            errorMessage: 'Error creating user data: $e',
            authState: AuthenticationState.unauthenticated,
            isLoading: false,
          );
        }
      },
    );
  }

  void _handleSignOut() {
    state = const UserState(
      authState: AuthenticationState.unauthenticated,
      isLoading: false,
      errorMessage: null,
    );

    _clearCachedUserData();
  }

  Future<void> _refreshUserDataInBackground(String userId) async {
    try {
      final result = await _readUserUseCase(userId);

      result.fold(
        (failure) {
          debugPrint('Background refresh failed: ${failure.message}');
        },
        (user) async {
          state = state.copyWith(userModel: user, errorMessage: null);
          await _cacheUserData(user);
        },
      );
    } catch (e) {
      debugPrint('Background refresh error: $e');
    }
  }

  Future<void> updateUserModel(UserModel user) async {
    state = state.copyWith(userModel: user, errorMessage: null);

    await _updateUserUseCase(user.toMap());

    _cacheUserData(user);
  }

  void completeRegistration(UserModel user) {
    updateUserModel(user);
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _signOutUseCase();

      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          );
        },
        (_) async {
          await _clearCachedUserData();
          state = const UserState(
            authState: AuthenticationState.unauthenticated,
            isLoading: false,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error signing out: $e',
        isLoading: false,
      );
    }
  }

  UserModel? getCachedUser() {
    return _userBox?.get(_currentUserKey);
  }

  bool get hasCachedUserData {
    return _userBox?.containsKey(_currentUserKey) ?? false;
  }

  Future<void> clearAllCache() async {
    try {
      await _userBox?.clear();
      state = state.copyWith(userModel: null);
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void _setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void forceAuthState(AuthenticationState newState) {
    state = state.copyWith(authState: newState);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userBox?.close();
    super.dispose();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(userProvider).userModel;
});

final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(userProvider).firebaseUser;
});
