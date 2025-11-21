import 'package:leakuku/domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
    );
  }
}
