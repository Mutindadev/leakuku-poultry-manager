import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';
import 'package:leakuku/features/auth/domain/use_case/register_with_email.dart';
import 'package:leakuku/features/auth/domain/use_case/sign_out.dart';
import 'package:leakuku/features/auth/domain/use_case/signin_with_email.dart';
import 'package:leakuku/features/user/data/models/user.dart';
import 'package:leakuku/features/user/domain/repositories/user_repository.dart';
import 'package:leakuku/features/user/domain/use_case/create.dart';
import 'package:leakuku/features/user/domain/use_case/read.dart';
import 'package:leakuku/features/user/domain/use_case/update.dart';
import 'package:leakuku/features/user/presentation/provider/user_provider.dart';

class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth(this.changes, this.user);

  final StreamController<User?> changes;
  final User? user;

  @override
  User? get currentUser => user;

  @override
  Stream<User?> authStateChanges() => changes.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseUser implements User {
  _FakeFirebaseUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseMessaging implements FirebaseMessaging {
  _FakeFirebaseMessaging(this.tokenChanges);

  final StreamController<String> tokenChanges;

  @override
  Stream<String> get onTokenRefresh => tokenChanges.stream;

  @override
  Future<String?> getToken({
    String? serviceWorkerScriptPath,
    String? vapidKey,
  }) async =>
      null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository(this.user);

  final UserModel user;

  @override
  Future<Either<Failure, UserModel>> readUser(String userId) async =>
      Right(user);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('auth restoration does not expose another account cached as current',
      () async {
    final directory = await Directory.systemTemp.createTemp();
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    final userBox = await Hive.openBox<UserModel>('userBox');

    final authChanges = StreamController<User?>();
    final tokenChanges = StreamController<String>();
    final firebaseUser = _FakeFirebaseUser('active-uid');
    final activeUser = _testUser('active-uid', 'Active Farmer');
    final staleUser = _testUser('other-uid', 'Other Farmer');
    final firebaseAuth = _FakeFirebaseAuth(authChanges, firebaseUser);
    final messaging = _FakeFirebaseMessaging(tokenChanges);
    final authRepository = _FakeAuthRepository();
    final userRepository = _FakeUserRepository(activeUser);

    await userBox.put('current_user', staleUser);

    final notifier = UserNotifier(
      firebaseAuth: firebaseAuth,
      firebaseMessaging: messaging,
      userBox: userBox,
      signOutUseCase: SignOutUseCase(repository: authRepository),
      readUserUseCase: ReadUserUseCase(repository: userRepository),
      signinWithEmailUseCase: SigninWithEmailUseCase(
        repository: authRepository,
      ),
      registerWithEmailUseCase: RegisterWithEmailUseCase(
        repository: authRepository,
      ),
      createUserUseCase: CreateUserUseCase(repository: userRepository),
      updateUserUseCase: UpdateUserUseCase(repository: userRepository),
    );
    final loaded = Completer<void>();
    notifier.addListener((state) {
      if (state.userModel?.uid == 'active-uid' && !loaded.isCompleted) {
        loaded.complete();
      }
    });

    authChanges.add(firebaseUser);
    await loaded.future.timeout(const Duration(seconds: 2));

    expect(notifier.state.userModel?.name, 'Active Farmer');
    expect(userBox.get('active-uid')?.uid, 'active-uid');
    expect(userBox.get('current_user')?.uid, 'other-uid');

    final signedOut = Completer<void>();
    notifier.addListener((state) {
      if (state.authState == AuthenticationState.unauthenticated &&
          state.userModel == null &&
          !signedOut.isCompleted) {
        signedOut.complete();
      }
    });
    authChanges.add(null);
    await signedOut.future.timeout(const Duration(seconds: 2));
    expect(notifier.state.userModel, isNull);

    notifier.dispose();
    await authChanges.close();
    await tokenChanges.close();
    await userBox.close();
    await Hive.deleteFromDisk();
    await directory.delete(recursive: true);
  });
}

UserModel _testUser(String uid, String name) {
  final now = DateTime(2025);
  return UserModel(
    uid: uid,
    name: name,
    email: '$uid@example.com',
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
}
