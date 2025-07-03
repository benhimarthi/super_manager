import 'package:equatable/equatable.dart';

abstract class AppImageSyncTriggerState extends Equatable {
  const AppImageSyncTriggerState();

  @override
  List<Object?> get props => [];
}

class AppImageSyncIdle extends AppImageSyncTriggerState {}

class AppImageSyncInProgress extends AppImageSyncTriggerState {}

class AppImageSyncSuccess extends AppImageSyncTriggerState {}

class AppImageSyncFailure extends AppImageSyncTriggerState {
  final String message;
  const AppImageSyncFailure(this.message);

  @override
  List<Object?> get props => [message];
}
