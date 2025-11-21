import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Data Sources
import 'package:leakuku/features/auth/data/auth_local_data_source.dart';
import 'package:leakuku/features/flock/data/flock_local_data_source.dart';

// Repositories
import 'package:leakuku/domain/repositories/auth_repository.dart';
import 'package:leakuku/domain/repositories/flock_repository.dart';
import 'package:leakuku/features/auth/data/auth_repository_impl.dart';
import 'package:leakuku/features/flock/data/flock_repository_impl.dart';

// Models
import 'package:leakuku/data/models/user_model.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';

// Use Cases
import 'package:leakuku/features/auth/domain/usecases/login_user.dart';
import 'package:leakuku/features/auth/domain/usecases/register_user.dart';

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

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final userBox = ref.watch(userBoxProvider);
  return AuthLocalDataSourceImpl(userBox: userBox);
});

final flockLocalDataSourceProvider = Provider<FlockLocalDataSource>((ref) {
  final flockBox = ref.watch(flockBoxProvider);
  return FlockLocalDataSourceImpl(flockBox: flockBox);
});

// === Repositories ===

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(localDataSource: localDataSource);
});

final flockRepositoryProvider = Provider<FlockRepository>((ref) {
  final localDataSource = ref.watch(flockLocalDataSourceProvider);
  return FlockRepositoryImpl(localDataSource: localDataSource);
});

// === Use Cases ===

final registerUserProvider = Provider<RegisterUser>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return RegisterUser(repo);
});

final loginUserProvider = Provider<LoginUser>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUser(repo);
});
