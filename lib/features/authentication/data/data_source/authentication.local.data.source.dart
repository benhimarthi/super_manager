import 'package:hive/hive.dart';
import '../../../../core/errors/custom.exception.dart';
import '../models/user.model.dart';

abstract class AuthenticationLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser(String email);
  Future<void> updateCachedUser(UserModel user);
  Future<void> removeCachedUser(String userId);
  Future<List<UserModel>> getCachedUsers();
  Future<void> markUserAsPending(String userId);
  Future<void> markUserAsUpdated(UserModel user);
  Future<void> markUserAsDeleted(String userId);
  Future<UserModel?> getCurrentUser();
  Future<bool> isUserMarkedAsPending(String userId);
  Future<void> clearPendingFlag(String userId);
  Future<List<UserModel>> getUpdatedUsers();
  Future<void> clearUpdateFlag(String userId);
  Future<List<String>> getDeletedUserIds();
  Future<void> clearDeletedFlag(String userId);
}

class AuthenticationLocalDataSrcImpl implements AuthenticationLocalDataSource {
  const AuthenticationLocalDataSrcImpl(this._hiveBox);

  final Box _hiveBox;

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _hiveBox.put(user.email, user.toMap());
    } catch (e) {
      throw const LocalException(
          message: "Failed to cache user", statusCode: 500);
    }
  }

  @override
  Future<UserModel?> getCachedUser(String email) async {
    try {
      final userData = _hiveBox.get(email);
      return userData != null ? UserModel.fromMap(userData) : null;
    } catch (e) {
      throw const LocalException(
          message: "Failed to retrieve cached user", statusCode: 500);
    }
  }

  @override
  Future<void> updateCachedUser(UserModel user) async {
    try {
      await _hiveBox.put(user.email, user.toMap());
    } catch (e) {
      throw const LocalException(
          message: "Failed to update cached user", statusCode: 500);
    }
  }

  @override
  Future<void> removeCachedUser(String userId) async {
    try {
      await _hiveBox.delete(userId);
    } catch (e) {
      throw const LocalException(
          message: "Failed to remove cached user", statusCode: 500);
    }
  }

  @override
  Future<List<UserModel>> getCachedUsers() async {
    try {
      final users = _hiveBox.values
          .map((userData) => UserModel.fromMap(userData))
          .toList();
      return users;
    } catch (e) {
      throw const LocalException(
          message: "Failed to retrieve cached users", statusCode: 500);
    }
  }

  /*@override
  Future<void> markUserAsDeleted(String userId) async {
    try {
      await _hiveBox.put(userId, {"deleted": true});
    } catch (e) {
      throw const LocalException(
          message: "Failed to mark user for deletion", statusCode: 500);
    }
  }*/

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _hiveBox.get("current_user");
      return currentUser != null ? UserModel.fromMap(currentUser) : null;
    } catch (e) {
      throw const LocalException(
          message: "Failed to retrieve current user", statusCode: 500);
    }
  }

  @override
  Future<void> markUserAsPending(String userId) async {
    final pendingUsers =
        _hiveBox.get("pending_users", defaultValue: <String>[]);
    if (!pendingUsers.contains(userId)) {
      pendingUsers.add(userId);
      await _hiveBox.put("pending_users", pendingUsers);
    }
  }

  @override
  Future<void> markUserAsUpdated(UserModel user) async {
    final updatedUsers =
        _hiveBox.get("updated_users", defaultValue: List<Map<String, dynamic>>);
    updatedUsers.removeWhere((u) {
      return u["id"] == user.id;
    }); // Prevent duplicate entries
    updatedUsers.add(user.toMap());
    await _hiveBox.put("updated_users", updatedUsers);
  }

  @override
  Future<void> markUserAsDeleted(String userId) async {
    final deletedUsers =
        _hiveBox.get("deleted_users", defaultValue: <String>[]);
    if (!deletedUsers.contains(userId)) {
      deletedUsers.add(userId);
      await _hiveBox.put("deleted_users", deletedUsers);
    }
  }

  @override
  Future<bool> isUserMarkedAsPending(String userId) async {
    final pendingUsers =
        _hiveBox.get("pending_users", defaultValue: <String>[]);
    return pendingUsers.contains(userId);
  }

  @override
  Future<void> clearPendingFlag(String userId) async {
    final pendingUsers =
        _hiveBox.get("pending_users", defaultValue: <String>[]);
    pendingUsers.remove(userId);
    await _hiveBox.put("pending_users", pendingUsers);
  }

  @override
  Future<List<UserModel>> getUpdatedUsers() async {
    final List<dynamic> rawList =
        _hiveBox.get("updated_users", defaultValue: []) as List<dynamic>;
    return rawList
        .map((data) => UserModel.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }

  @override
  Future<void> clearUpdateFlag(String userId) async {
    final updatedUsers = _hiveBox
        .get("updated_users", defaultValue: <List<Map<String, dynamic>>>[]);
    updatedUsers.removeWhere((userData) => userData["id"] == userId);
    await _hiveBox.put("updated_users", updatedUsers);
  }

  @override
  Future<List<String>> getDeletedUserIds() async {
    return _hiveBox.get("deleted_users", defaultValue: <String>[]);
  }

  @override
  Future<void> clearDeletedFlag(String userId) async {
    final deletedUsers =
        _hiveBox.get("deleted_users", defaultValue: <String>[]);
    deletedUsers.remove(userId);
    await _hiveBox.put("deleted_users", deletedUsers);
  }
}
