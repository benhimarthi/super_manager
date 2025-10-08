import 'package:equatable/equatable.dart';

abstract class CustomException extends Equatable implements Exception {
  const CustomException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class APIException extends CustomException {
  const APIException({required super.message, required super.statusCode});
}

class NetworkException extends CustomException {
  const NetworkException({required super.message, required super.statusCode});
}

class ServerException extends CustomException {
  const ServerException({required super.message, required super.statusCode});
}

class LocalException extends CustomException {
  const LocalException({required super.message, required super.statusCode});
}
