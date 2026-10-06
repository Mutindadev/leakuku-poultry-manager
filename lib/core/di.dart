import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
// Models
import 'package:leakuku/data/models/user_model.dart';
import 'package:leakuku/domain/repositories/flock_repository.dart';
import 'package:leakuku/features/auth/data/data_sources/remote.dart';
import 'package:leakuku/features/auth/data/data_sources/remote_implementation.dart';
import 'package:leakuku/features/auth/data/repositories/auth_implementation.dart';
import 'package:leakuku/features/auth/domain/repositories/auth_repository.dart';
// Repositories
import 'package:leakuku/features/flock/data/data_sources/flock_local_data_source.dart';
import 'package:leakuku/features/flock/data/repositories/flock_repository_impl.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';

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

final flockLocalDataSourceProvider = Provider<FlockLocalDataSource>((ref) {
  final flockBox = ref.watch(flockBoxProvider);
  return FlockLocalDataSourceImpl(flockBox: flockBox);
});

// === Repositories ===

// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   final localDataSource = ref.watch(authLocalDataSourceProvider);
//   return AuthRepositoryImplementation(
//       remoteDataSource: AuthRemoteDataSourceImplementation());
// });

final flockRepositoryProvider = Provider<FlockRepository>((ref) {
  final localDataSource = ref.watch(flockLocalDataSourceProvider);
  return FlockRepositoryImpl(localDataSource: localDataSource);
});

// === Use Cases ===

// final registerUserProvider = Provider<RegisterUser>((ref) {
//   final repo = ref.watch(authRepositoryProvider);
//   return RegisterUser(repo);
// });

// final loginUserProvider = Provider<LoginUser>((ref) {
//   final repo = ref.watch(authRepositoryProvider);
//   return LoginUser(repo);
// });
