import 'package:equatable/equatable.dart';

enum UserRole { admin, regular }

class User extends Equatable {
  final String id;
  final String createdAt;
  final String name;
  final String avatar;
  final String email;
  final String password;
  final UserRole role;

  const User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.avatar,
    required this.email,
    required this.password,
    required this.role,
  });

  const User.empty()
      : this(
          id: '0',
          createdAt: "_empty.createdAt",
          name: "_empty.name",
          avatar: "_empty.avatar",
          email: "_empty.email",
          password: "_empty.password",
          role: UserRole.regular,
        );

  @override
  List<Object?> get props => [id, name, email, avatar, role];
}
