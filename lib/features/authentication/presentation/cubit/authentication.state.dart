import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

// Loading state (used during any async process)
class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();
}

// Error state with message
class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Offline state when action is pending
class AuthenticationOfflinePending extends AuthenticationState {
  const AuthenticationOfflinePending();
}

// State when a user has been successfully created
class UserCreated extends AuthenticationState {
  const UserCreated();
}

// State when a user has been successfully updated
class UserUpdated extends AuthenticationState {
  const UserUpdated();
}

// State when a user has been successfully deleted
class UserDeleted extends AuthenticationState {
  const UserDeleted();
}

// State when the user is successfully authenticated (logged in or from getCurrentUser)
class UserAuthenticated extends AuthenticationState {
  final User user;

  const UserAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// State when all users are loaded (e.g. after create/update/delete)
class UsersLoaded extends AuthenticationState {
  final List<User> users;

  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}
