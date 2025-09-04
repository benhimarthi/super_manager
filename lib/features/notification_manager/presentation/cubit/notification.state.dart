import 'package:equatable/equatable.dart';

import '../../domain/entities/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object> get props => [];
}

class NotificationManagerInitial extends NotificationState {}

class NotificationManagerLoading extends NotificationState {}

class NotificationManagerLoaded extends NotificationState {
  final List<Notifications> notifications;
  const NotificationManagerLoaded(this.notifications);
  @override
  List<Object> get props => [notifications];
}

class NotificationManagerError extends NotificationState {
  final String message;
  const NotificationManagerError(this.message);
  @override
  List<Object> get props => [message];
}
