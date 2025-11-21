import 'package:hive/hive.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(UserModel user, String password);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> userBox;

  AuthLocalDataSourceImpl({required this.userBox});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final target = email.trim().toLowerCase();
      final user = userBox.values.firstWhere((u) => u.email.trim().toLowerCase() == target);
      return user;
    } on StateError {
      throw AuthFailure('Invalid email or password.');
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserModel> register(UserModel user, String password) async {
    final incomingEmail = user.email.trim().toLowerCase();
    final existingUser = userBox.values
        .where((u) => u.email.trim().toLowerCase() == incomingEmail)
        .cast<UserModel?>()
        .firstWhere((_) => true, orElse: () => null);

    if (existingUser != null) {
      throw AuthFailure('User with this email already exists.');
    }

    final newUser = UserModel(
      id: incomingEmail, // normalize id
      name: user.name,
      email: incomingEmail,
      role: user.role,
    );

    await userBox.put(newUser.email, newUser);
    return newUser;
  }
}
