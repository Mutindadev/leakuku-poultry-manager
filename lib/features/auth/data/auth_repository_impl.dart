import 'package:dartz/dartz.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/domain/entities/user.dart';
import 'package:leakuku/domain/repositories/auth_repository.dart';
import 'package:leakuku/features/auth/data/auth_local_data_source.dart';
import 'package:leakuku/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  // Map UserModel to domain User entity
  User _toEntity(UserModel model) {
    return User(
      id: model.id,
      name: model.name,
      email: model.email,
      role: model.role,
    );
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await localDataSource.login(email, password);
      return Right(_toEntity(userModel));
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register(
      String name, String email, String password) async {
    try {
      final userModel = UserModel(
        id: email.trim().toLowerCase(),
        name: name,
        email: email.trim().toLowerCase(),
        role: 'Farmer', // Default role
      );
      final newUserModel = await localDataSource.register(userModel, password);
      return Right(_toEntity(newUserModel));
    } on AuthFailure catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }
}
