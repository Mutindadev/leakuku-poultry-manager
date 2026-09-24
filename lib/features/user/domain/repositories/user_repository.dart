import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/user/data/models/user.dart';

abstract class UserRepository {
  const UserRepository();

  ResultFuture<void> createUser(UserModel userModel);

  ResultFuture<List<UserModel>> readAllUsers();

  ResultFuture<UserModel> readUser(String userId);

  ResultFuture<void> updateUser(
    // UserModel userModel,
    DataMap updateData,
  );

  ResultFuture<void> deleteUser(String userId);
}
