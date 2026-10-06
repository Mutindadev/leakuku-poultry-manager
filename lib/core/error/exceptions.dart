import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  final String message;
  final int statusCode;

  const ServerException({
    required this.message,
    required this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode];
}

class CacheException extends Equatable implements Exception {
  final String message;
  final int statusCode;

  const CacheException({
    required this.message,
    required this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode];
}

class NetworkException extends Equatable implements Exception {
  final String message;
  final int statusCode;

  const NetworkException({
    required this.message,
    required this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode];
}

class UnknownException extends Equatable implements Exception {
  final String message;
  final int statusCode;

  const UnknownException({
    required this.message,
    required this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode];
}

class AuthException extends Equatable implements Exception {
  final String message;
  final int statusCode;

  const AuthException({
    required this.message,
    required this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode];
}

class ApiException extends Equatable implements Exception {
  final String message;
  final int statusCode;

  const ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode];
}
