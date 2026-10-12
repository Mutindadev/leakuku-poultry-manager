import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/core/providers/firestore_data_providers.dart';
import 'package:leakuku/core/providers/platform_providers.dart';
import 'package:leakuku/core/services/firestore_sync_coordinator.dart';
// Models
import 'package:leakuku/domain/repositories/flock_repository.dart';
import 'package:leakuku/features/auth/data/data_sources/remote.dart';
import 'package:leakuku/features/auth/data/data_sources/remote_implementation.dart';
import 'package:leakuku/features/auth/data/repositories/auth_implementation.dart';
import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';
import 'package:leakuku/features/auth/domain/use_case/register_with_email.dart';
import 'package:leakuku/features/auth/domain/use_case/sign_out.dart';
import 'package:leakuku/features/auth/domain/use_case/signin_with_email.dart';
// Repositories
import 'package:leakuku/features/flock/data/data_sources/flock_local_data_source.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';
import 'package:leakuku/features/flock/data/repositories/flock_repository_impl.dart';
import 'package:leakuku/features/user/data/data_sources/remote.dart';
import 'package:leakuku/features/user/data/data_sources/remote_implementation.dart';
import 'package:leakuku/features/user/data/models/user.dart';
import 'package:leakuku/features/user/data/repositories/user_implementation.dart';
import 'package:leakuku/features/user/domain/repositories/user_repository.dart';
import 'package:leakuku/features/user/domain/use_case/create.dart';
import 'package:leakuku/features/user/domain/use_case/read.dart';
import 'package:leakuku/features/user/domain/use_case/update.dart';

// === Hive Boxes ===

final userBoxProvider = Provider<Box<UserModel>>((ref) {
  return Hive.box<UserModel>('userBox');
});

final flockBoxProvider = Provider<Box<FlockModel>>((ref) {
  if (!Hive.isBoxOpen('flockBox')) {
    throw Exception('Flock Box not initialized');
  }
  return Hive.box<FlockModel>('flockBox');
});

// === Local Data Sources ===

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImplementation();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImplementation(remoteDataSource: remoteDataSource);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(repository: ref.watch(authRepositoryProvider));
});

final signInWithEmailUseCaseProvider = Provider<SigninWithEmailUseCase>((ref) {
  return SigninWithEmailUseCase(repository: ref.watch(authRepositoryProvider));
});

final registerWithEmailUseCaseProvider =
    Provider<RegisterWithEmailUseCase>((ref) {
  return RegisterWithEmailUseCase(
      repository: ref.watch(authRepositoryProvider));
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSourseImlementation();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImplementation(
    remoteDataSource: ref.watch(userRemoteDataSourceProvider),
  );
});

final createUserUseCaseProvider = Provider<CreateUserUseCase>((ref) {
  return CreateUserUseCase(repository: ref.watch(userRepositoryProvider));
});

final readUserUseCaseProvider = Provider<ReadUserUseCase>((ref) {
  return ReadUserUseCase(repository: ref.watch(userRepositoryProvider));
});

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>((ref) {
  return UpdateUserUseCase(repository: ref.watch(userRepositoryProvider));
});

final flockLocalDataSourceProvider = Provider<FlockLocalDataSource>((ref) {
  final flockBox = ref.watch(flockBoxProvider);
  return FlockLocalDataSourceImpl(
    flockBox: flockBox,
    syncQueue: ref.watch(firestoreSyncQueueProvider),
  );
});

final flockRepositoryProvider = Provider<FlockRepository>((ref) {
  final localDataSource = ref.watch(flockLocalDataSourceProvider);
  return FlockRepositoryImpl(localDataSource: localDataSource);
});

final firestoreSyncCoordinatorProvider =
    Provider<FirestoreSyncCoordinator>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final connectivity = ref.watch(connectivityProvider);
  final backupService = ref.watch(firestoreBackupServiceProvider);
  final coordinator = FirestoreSyncCoordinator(
    userIdChanges: auth.authStateChanges().map((user) => user?.uid),
    connectivityChanges: connectivity.onConnectivityChanged,
    currentUserId: () => auth.currentUser?.uid,
    syncUser: backupService.syncUser,
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});
