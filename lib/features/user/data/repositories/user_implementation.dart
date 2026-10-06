import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/user/data/data_sources/remote.dart';
import 'package:leakuku/features/user/data/models/user.dart';
import 'package:leakuku/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImplementation implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  const UserRepositoryImplementation({required this.remoteDataSource});

  @override
  ResultFuture<void> createUser(UserModel userModel) async {
    return await remoteDataSource.createUser(userModel);
  }

  @override
  ResultFuture<List<UserModel>> readAllUsers() {
    return remoteDataSource.readAllUsers();
  }

  @override
  ResultFuture<UserModel> readUser(String userId) {
    return remoteDataSource.readUser(userId);
  }

  @override
  ResultFuture<void> updateUser(DataMap updateData) {
    return remoteDataSource.updateUser(updateData);
  }

  @override
  ResultFuture<void> deleteUser(String userId) {
    return remoteDataSource.deleteUser(userId);
  }
}
