import 'package:equatable/equatable.dart';

import 'custom.exception.dart';

abstract class Failure extends Equatable {
  final String message;
  final int statusCode;

  String get errorMessage => "$statusCode Error: $message";

  const Failure({required this.message, required this.statusCode});

  @override
  List<Object> get props => [message, statusCode];
}

class APIFailure extends Failure {
  const APIFailure({required String message, required int statusCode})
      : super(message: message, statusCode: statusCode);

  factory APIFailure.fromException(APIException exception) =>
      APIFailure(message: exception.message, statusCode: exception.statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message, required int statusCode})
      : super(message: message, statusCode: statusCode);
}

class ServerFailure extends Failure {
  const ServerFailure({required String message, required int statusCode})
      : super(message: message, statusCode: statusCode);
}

class LocalFailure extends Failure {
  const LocalFailure({
    required String message,
    required int statusCode,
  }) : super(
          message: message,
          statusCode: statusCode,
        );
  factory LocalFailure.fromLocalException(LocalException exc) => LocalFailure(
        message: exc.message,
        statusCode: exc.statusCode,
      );
}
