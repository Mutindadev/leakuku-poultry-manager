import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];

  String? get message => null;
}

class AuthFailure extends Failure {
  @override
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class DataNotFoundFailure extends Failure {}

class CacheFailure extends Failure {
  @override
  final String message;

  CacheFailure([this.message = 'Cache failure occurred']);
}
