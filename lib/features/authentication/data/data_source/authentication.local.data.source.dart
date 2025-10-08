import 'package:hive/hive.dart';
import 'package:super_manager/core/errors/failure.dart';

import '../models/user.model.dart';

abstract class AuthenticationLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String id);

  Future<UserModel?> getUserById(String id);
  Future<UserModel?> getUserByEmail(String email);
  Future<List<UserModel>> getUsersForCreator(String creatorId);

  // Current User
  Future<void> cacheCurrentUser(UserModel user);
  Future<UserModel?> getCurrentUser();
  Future<void> clearCurrentUser();

  // 🔁 Sync staging
  Future<void> stageCreatedUser(UserModel user);
  Future<void> stageUpdatedUser(UserModel user);
  Future<void> stageDeletedUser(String id);

  Future<List<UserModel>> getCreatedUsers();
  Future<List<UserModel>> getUpdatedUsers();
  Future<List<String>> getDeletedUserIds();

  Future<void> clearCreatedUser(String id);
  Future<void> clearUpdatedUser(String id);
  Future<void> clearDeletedUser(String id);
  Future<void> clearAll();

  // Apply changes from remote
  Future<void> applyCreate(UserModel user);
  Future<void> applyUpdate(UserModel user);
  Future<void> applyDelete(String id);
}

class AuthenticationLocalDataSourceImpl implements AuthenticationLocalDataSource {
  final Box mainBox;
  final Box createdBox;
  final Box updatedBox;
  final Box deletedBox;

  AuthenticationLocalDataSourceImpl({
    required this.mainBox,
    required this.createdBox,
    required this.updatedBox,
    required this.deletedBox,
  });

  // Main store
  @override
  Future<void> cacheUser(UserModel user) async {
    await mainBox.put(user.id, user.toMap());
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await mainBox.put(user.id, user.toMap());
  }

  @override
  Future<void> deleteUser(String id) async {
    await mainBox.delete(id);
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    final data = mainBox.get(id);
    if (data == null) return null;
    return UserModel.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    for (final value in mainBox.values) {
      final userMap = Map<String, dynamic>.from(value as Map);
      if (userMap['id'] != 'CURRENT_USER' && userMap['email'] == email) {
        return UserModel.fromMap(userMap);
      }
    }
    return null;
  }

  @override
  Future<List<UserModel>> getUsersForCreator(String creatorId) async {
    try {
      return mainBox.values
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((e) => e['id'] != 'CURRENT_USER' && e['createdBy'] == creatorId)
          .map((e) => UserModel.fromMap(e))
          .toList();
    } catch (e) {
      throw LocalFailure(message: e.toString(), statusCode: 500);
    }
  }

  // Current User
  @override
  Future<void> cacheCurrentUser(UserModel user) async {
    await mainBox.put('CURRENT_USER', user.toMap());
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final data = mainBox.get('CURRENT_USER');
    if (data == null) return null;
    return UserModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> clearCurrentUser() async {
    await mainBox.delete('CURRENT_USER');
  }

  // ➕ Create Staging
  @override
  Future<void> stageCreatedUser(UserModel user) async {
    await cacheUser(user);
    await createdBox.put(user.id, user.toMap());
  }

  @override
  Future<List<UserModel>> getCreatedUsers() async {
    return createdBox.values
        .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> clearCreatedUser(String id) async {
    await createdBox.delete(id);
  }

  // 🛠️ Update Staging
  @override
  Future<void> stageUpdatedUser(UserModel user) async {
    await updateUser(user);
    await updatedBox.put(user.id, user.toMap());
  }

  @override
  Future<List<UserModel>> getUpdatedUsers() async {
    return updatedBox.values
        .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> clearUpdatedUser(String id) async {
    await updatedBox.delete(id);
  }

  // ❌ Delete Staging
  @override
  Future<void> stageDeletedUser(String id) async {
    await deleteUser(id);
    await deletedBox.put(id, {'id': id});
  }

  @override
  Future<List<String>> getDeletedUserIds() async {
    return deletedBox.values.map((e) => (e as Map)['id'] as String).toList();
  }

  @override
  Future<void> clearDeletedUser(String id) async {
    await deletedBox.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await mainBox.clear();
    await createdBox.clear();
    await updatedBox.clear();
    await deletedBox.clear();
  }

  @override
  Future<void> applyCreate(UserModel user) async {
    await mainBox.put(user.id, user.toMap());
  }

  @override
  Future<void> applyUpdate(UserModel user) async {
    await mainBox.put(user.id, user.toMap());
  }

  @override
  Future<void> applyDelete(String id) async {
    await mainBox.delete(id);
  }
}
