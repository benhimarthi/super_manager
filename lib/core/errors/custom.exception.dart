import 'package:equatable/equatable.dart';

abstract class CustomException extends Equatable implements Exception {
  const CustomException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class APIException extends CustomException {
  const APIException({required String message, required int statusCode})
      : super(message: message, statusCode: statusCode);
}

class NetworkException extends CustomException {
  const NetworkException({required String message, required int statusCode})
      : super(message: message, statusCode: statusCode);
}

class ServerException extends CustomException {
  const ServerException({required String message, required int statusCode})
      : super(message: message, statusCode: statusCode);
}

class LocalException extends CustomException {
  const LocalException({required String message, required int statusCode})
      : super(
          message: message,
          statusCode: statusCode,
        );
}
