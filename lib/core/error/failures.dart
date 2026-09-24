import 'package:equatable/equatable.dart';
import 'package:leakuku/core/error/exceptions.dart';

abstract class Failure extends Equatable {
  final String message;
  final int statusCode;

  const Failure({required this.message, required this.statusCode});

  @override
  List<Object> get props => [message, statusCode];
}

class ApiFailure extends Failure {
  const ApiFailure({required super.message, required super.statusCode});

  ApiFailure.fromException(ApiException exception)
      : this(message: exception.message, statusCode: exception.statusCode);
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, required super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, required super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, required super.statusCode});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, required super.statusCode});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, required super.statusCode});
}
