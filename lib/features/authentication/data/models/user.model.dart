import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.createdAt,
    required super.name,
    required super.avatar,
    required super.email,
    required super.password,
    required super.role,
  });

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory UserModel.fromUser(User user) {
    return UserModel(
      id: user.id,
      createdAt: user.createdAt,
      name: user.name,
      avatar: user.avatar,
      email: user.email,
      password: user.password,
      role: user.role,
    );
  }

  UserModel.fromMap(Map<dynamic, dynamic> map)
      : this(
          id: map['id'] as String,
          createdAt: map['createdAt'] as String,
          name: map['name'] as String,
          avatar: map['avatar'] as String,
          email: map['email'] as String,
          password: "empty",
          role: UserRole.values.firstWhere((e) => e.toString() == map['role']),
        );

  const UserModel.empty()
      : this(
          id: '0',
          createdAt: "_empty.createdAt",
          name: "_empty.name",
          avatar: "_empty.avatar",
          email: "_empty.email",
          password: "_empty.password",
          role: UserRole.regular,
        );

  UserModel copyWith({
    String? id,
    String? createdAt,
    String? name,
    String? avatar,
    String? email,
    String? password,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt,
        'name': name,
        'avatar': avatar,
        'email': email,
        'role': role.toString(),
      };

  String toJson() => jsonEncode(toMap());
}
