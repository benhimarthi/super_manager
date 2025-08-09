import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.createdAt,
    super.createdBy,
    super.administratorId,
    required super.name,
    required super.avatar,
    required super.email,
    required super.password,
    required super.role,
    super.activated,
  });

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory UserModel.fromUser(User user) {
    return UserModel(
      id: user.id,
      administratorId: user.administratorId,
      createdAt: user.createdAt,
      createdBy: user.createdBy,
      name: user.name,
      avatar: user.avatar,
      email: user.email,
      password: user.password,
      role: user.role,
      activated: user.activated,
    );
  }

  UserModel.fromMap(Map<dynamic, dynamic> map)
    : this(
        id: map['id'] as String,
        administratorId: (map['administratorId'] ?? "") as String,
        createdAt: map['createdAt'] as String,
        createdBy: (map['createdBy'] ?? "") as String,
        name: map['name'] as String,
        avatar: map['avatar'] as String,
        email: map['email'] as String,
        password: "empty",
        role: UserRole.values.firstWhere((e) => e.toString() == map['role']),
        activated: map['activated'] ?? true,
      );

  const UserModel.empty()
    : this(
        id: '0',
        administratorId: "_empty.adminId",
        createdAt: "_empty.createdAt",
        createdBy: "_empty.createdAt",
        name: "_empty.name",
        avatar: "_empty.avatar",
        email: "_empty.email",
        password: "_empty.password",
        role: UserRole.regular,
        activated: false,
      );

  UserModel copyWith({
    String? id,
    String? administratorId,
    String? createdAt,
    String? createdBy,
    String? name,
    String? avatar,
    String? email,
    String? password,
    UserRole? role,
    bool? activated,
  }) {
    return UserModel(
      id: id ?? this.id,
      administratorId: administratorId ?? this.administratorId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      activated: activated ?? this.activated,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'administratorId': administratorId,
    'createdAt': createdAt,
    'createdBy': createdBy,
    'name': name,
    'avatar': avatar,
    'email': email,
    'role': role.toString(),
    'activated': activated,
  };

  String toJson() => jsonEncode(toMap());
}
