import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
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
      updatedAt: user.updatedAt,
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
          createdAt: DateTime.parse(map['createdAt'] as String),
          updatedAt: DateTime.parse(map['updatedAt'] as String),
          createdBy: (map['createdBy'] ?? "") as String,
          name: map['name'] as String,
          avatar: map['avatar'] as String,
          email: map['email'] as String,
          password: "empty",
          role: UserRole.values.firstWhere((e) => e.toString() == map['role']),
          activated: map['activated'] ?? true,
        );

  UserModel.empty()
      : this(
          id: '0',
          administratorId: "_empty.adminId",
          createdAt: DateTime.fromMicrosecondsSinceEpoch(0),
          updatedAt: DateTime.fromMicrosecondsSinceEpoch(0),
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
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
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'createdBy': createdBy,
        'name': name,
        'avatar': avatar,
        'email': email,
        'role': role.toString(),
        'activated': activated,
      };

  String toJson() => jsonEncode(toMap());
}
