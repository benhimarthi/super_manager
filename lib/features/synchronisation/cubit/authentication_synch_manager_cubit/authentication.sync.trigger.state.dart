import 'package:equatable/equatable.dart';

abstract class AuthenticationSyncTriggerState extends Equatable {
  const AuthenticationSyncTriggerState();

  @override
  List<Object?> get props => [];
}

class SyncInitial extends AuthenticationSyncTriggerState {}

class SyncInProgress extends AuthenticationSyncTriggerState {}

class SyncSuccess extends AuthenticationSyncTriggerState {}

class SyncFailure extends AuthenticationSyncTriggerState {
  final String error;

  const SyncFailure(this.error);

  @override
  List<Object?> get props => [error];
}
