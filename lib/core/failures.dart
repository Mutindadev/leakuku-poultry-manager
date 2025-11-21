import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object?> get props => [properties];
  
  get properties => null;
}

// General failures
class ServerFailure extends Failure {}
class CacheFailure extends Failure {}

// Auth failures
class AuthFailure extends Failure {
  final String message;
  const AuthFailure(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Data failures
class DataNotFoundFailure extends Failure {}
class InvalidInputFailure extends Failure {}
