import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/core/di.dart';
import 'package:leakuku/core/providers/platform_providers.dart';
import 'package:leakuku/features/auth/domain/use_case/register_with_email.dart';
import 'package:leakuku/features/auth/domain/use_case/sign_out.dart';
import 'package:leakuku/features/auth/domain/use_case/signin_with_email.dart';
import 'package:leakuku/features/user/data/models/user.dart';
import 'package:leakuku/features/user/domain/use_case/create.dart';
import 'package:leakuku/features/user/domain/use_case/read.dart';
import 'package:leakuku/features/user/domain/use_case/update.dart';

enum AuthenticationState { unknown, authenticated, unauthenticated }

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
  static const String _legacyUserKey = 'current_user';

  UserNotifier({
    required FirebaseAuth firebaseAuth,
    required FirebaseMessaging firebaseMessaging,
    required Box<UserModel> userBox,
    required SignOutUseCase signOutUseCase,
    required ReadUserUseCase readUserUseCase,
    required SigninWithEmailUseCase signinWithEmailUseCase,
    required RegisterWithEmailUseCase registerWithEmailUseCase,
    required CreateUserUseCase createUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
  })  : _firebaseAuth = firebaseAuth,
        _firebaseMessaging = firebaseMessaging,
        _userBox = userBox,
        _signOutUseCase = signOutUseCase,
        _readUserUseCase = readUserUseCase,
        _signinWithEmailUseCase = signinWithEmailUseCase,
        _registerWithEmailUseCase = registerWithEmailUseCase,
        _createUserUseCase = createUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        super(const UserState()) {
    _authSubscription = _firebaseAuth.authStateChanges().listen(
      _handleAuthChange,
      onError: (Object error) {
        if (mounted) {
          state = state.copyWith(
            errorMessage: error.toString(),
            isLoading: false,
          );
        }
      },
    );
    _tokenSubscription = _firebaseMessaging.onTokenRefresh.listen(
      (token) => unawaited(_refreshFcmToken(token)),
      onError: (Object error) => debugPrint('FCM token refresh failed: $error'),
    );
  }

  final FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _firebaseMessaging;
  final Box<UserModel> _userBox;
  final SignOutUseCase _signOutUseCase;
  final ReadUserUseCase _readUserUseCase;
  final SigninWithEmailUseCase _signinWithEmailUseCase;
  final RegisterWithEmailUseCase _registerWithEmailUseCase;
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final Map<String, Future<void>> _userLoads = {};
  late final StreamSubscription<User?> _authSubscription;
  late final StreamSubscription<String> _tokenSubscription;

  Future<void> _cacheUserData(UserModel user) async {
    try {
      await _userBox.put(user.uid, user);
    } catch (e) {
      debugPrint('Error caching user data: $e');
    }
  }

  Future<UserModel?> _readCachedUser(String uid) async {
    final cachedUser = _userBox.get(uid);
    if (cachedUser != null) return cachedUser;

    final legacyUser = _userBox.get(_legacyUserKey);
    if (legacyUser?.uid != uid) return null;

    await _cacheUserData(legacyUser!);
    return legacyUser;
  }

  Future<void> _handleAuthChange(User? user) async {
    if (user == null) {
      state = const UserState(authState: AuthenticationState.unauthenticated);
      return;
    }
    await _loadAuthenticatedUser(user);
  }

  Future<void> _loadAuthenticatedUser(User user) {
    final pendingLoad = _userLoads[user.uid];
    if (pendingLoad != null) return pendingLoad;

    final load = _loadAuthenticatedUserOnce(user);
    _userLoads[user.uid] = load;
    return load.whenComplete(() => _userLoads.remove(user.uid));
  }

  Future<void> _loadAuthenticatedUserOnce(User user) async {
    if (!mounted || _firebaseAuth.currentUser?.uid != user.uid) return;
    state = UserState(
      firebaseUser: user,
      authState: AuthenticationState.authenticated,
      isLoading: true,
    );

    UserModel? cachedUser;
    try {
      cachedUser = await _readCachedUser(user.uid);
    } catch (error) {
      debugPrint('Could not read cached user data: $error');
    }
    if (!mounted || _firebaseAuth.currentUser?.uid != user.uid) return;

    state = UserState(
      firebaseUser: user,
      userModel: cachedUser,
      authState: AuthenticationState.authenticated,
      isLoading: cachedUser == null,
    );

    try {
      final result = await _readUserUseCase(user.uid);
      await result.fold<Future<void>>(
        (failure) async {
          if (!_isCurrentUser(user.uid)) return;
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          );
          if (cachedUser != null) {
            await _refreshFcmTokenFor(user.uid, currentUser: cachedUser);
          }
        },
        (userModel) async {
          if (!_isCurrentUser(user.uid)) return;
          state = state.copyWith(userModel: userModel, isLoading: false);
          await _cacheUserData(userModel);
          await _refreshFcmTokenFor(user.uid, currentUser: userModel);
        },
      );
    } catch (error) {
      if (!_isCurrentUser(user.uid)) return;
      state = state.copyWith(
        errorMessage: 'Error fetching user data: $error',
        isLoading: false,
      );
    }
  }

  bool _isCurrentUser(String uid) =>
      mounted &&
      state.firebaseUser?.uid == uid &&
      _firebaseAuth.currentUser?.uid == uid;

  Future<void> _refreshFcmToken(String token) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;
    await _refreshFcmTokenFor(uid, token: token);
  }

  Future<void> _refreshFcmTokenFor(
    String uid, {
    UserModel? currentUser,
    String? token,
  }) async {
    try {
      final fcmToken = token ?? await _firebaseMessaging.getToken();
      if (fcmToken == null || fcmToken.isEmpty || !_isCurrentUser(uid)) return;

      final cachedUser = currentUser ?? state.userModel;
      if (cachedUser == null || cachedUser.uid != uid) return;
      if (cachedUser.fcmToken == fcmToken) return;

      final now = DateTime.now();
      final updatedUser = cachedUser.copyWith(
        fcmToken: fcmToken,
        updatedAt: now,
        lastLocalModifiedAt: now,
      );
      state = state.copyWith(userModel: updatedUser);
      await _cacheUserData(updatedUser);

      final result = await _updateUserUseCase(updatedUser.toMap());
      result.fold(
        (failure) => debugPrint('Could not sync FCM token: ${failure.message}'),
        (_) {},
      );
    } catch (error) {
      debugPrint('Could not refresh FCM token: $error');
    }
  }

  Future<void> handleSignIn(String email, String password) async {
    state = const UserState(isLoading: true);
    try {
      final result = await _signinWithEmailUseCase(email, password);
      await result.fold<Future<void>>(
        (failure) async {
          state = UserState(
            authState: AuthenticationState.unauthenticated,
            errorMessage: failure.message,
          );
        },
        _loadAuthenticatedUser,
      );
    } catch (error) {
      state = UserState(
        authState: AuthenticationState.unauthenticated,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> handleRegister(
    String email,
    String password,
    String name,
  ) async {
    state = const UserState(isLoading: true);
    try {
      final result = await _registerWithEmailUseCase(email, password, name);
      await result.fold<Future<void>>(
        (failure) async {
          state = UserState(
            authState: AuthenticationState.unauthenticated,
            errorMessage: failure.message,
          );
        },
        (firebaseUser) async {
          final now = DateTime.now();
          final userModel = UserModel(
            uid: firebaseUser.uid,
            name: name,
            email: firebaseUser.email ?? '',
            role: 'farmer',
            phonenumber: '',
            flockIds: [],
            activeFlocks: [],
            fcmToken: '',
            isOnline: false,
            createdAt: now,
            updatedAt: now,
            lastSyncedAt: now,
            lastLocalModifiedAt: now,
          );

          final createResult = await _createUserUseCase(userModel);
          await createResult.fold<Future<void>>(
            (failure) async {
              state = UserState(
                firebaseUser: firebaseUser,
                authState: AuthenticationState.authenticated,
                errorMessage: failure.message,
              );
            },
            (_) async {
              state = UserState(
                userModel: userModel,
                firebaseUser: firebaseUser,
                authState: AuthenticationState.authenticated,
              );
              await _cacheUserData(userModel);
              await _refreshFcmTokenFor(
                firebaseUser.uid,
                currentUser: userModel,
              );
            },
          );
        },
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Error creating user data: $error',
        isLoading: false,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _signOutUseCase();
      await result.fold<Future<void>>(
        (failure) async {
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          );
        },
        (_) async {
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
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return null;
    return _userBox.get(uid);
  }

  bool get hasCachedUserData => getCachedUser() != null;

  Future<void> clearAllCache() async {
    try {
      await _userBox.clear();
      state = UserState(
        firebaseUser: state.firebaseUser,
        authState: state.authState,
        isLoading: state.isLoading,
      );
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);

  @override
  void dispose() {
    _authSubscription.cancel();
    _tokenSubscription.cancel();
    super.dispose();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firebaseMessaging: ref.watch(firebaseMessagingProvider),
    userBox: ref.watch(userBoxProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    readUserUseCase: ref.watch(readUserUseCaseProvider),
    signinWithEmailUseCase: ref.watch(signInWithEmailUseCaseProvider),
    registerWithEmailUseCase: ref.watch(registerWithEmailUseCaseProvider),
    createUserUseCase: ref.watch(createUserUseCaseProvider),
    updateUserUseCase: ref.watch(updateUserUseCaseProvider),
  );
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(userProvider).userModel;
});

final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(userProvider).firebaseUser;
});
