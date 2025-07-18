import 'package:equatable/equatable.dart';

enum UserRole { admin, seller, inventoryManger, regular }

class User extends Equatable {
  final String id;
  final String createdAt;
  final String? createdBy;
  final String name;
  final String avatar;
  final String email;
  final String password;
  final UserRole role;
  final bool? activated;

  const User({
    required this.id,
    required this.createdAt,
    this.createdBy,
    required this.name,
    required this.avatar,
    required this.email,
    required this.password,
    required this.role,
    this.activated,
  });

  const User.empty()
    : this(
        id: '0',
        createdAt: "_empty.createdAt",
        createdBy: "_empty.createdBy",
        name: "_empty.name",
        avatar: "_empty.avatar",
        email: "_empty.email",
        password: "_empty.password",
        role: UserRole.regular,
        activated: false,
      );

  @override
  List<Object?> get props => [id, name, email, avatar, role];
}
