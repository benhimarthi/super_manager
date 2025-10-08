import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/session/session.manager.dart';

import 'authentication.local.data.source.dart';
import 'authentictaion.remote.data.source.dart';
import '../models/user.model.dart';

abstract class UserSyncManager {
  Future<void> syncData();
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
  Future<void> resetAccountPassword(String email);
  Future<void> renewEmailAccount(String email);
  void startListeningToRemoteChanges();
  void stopListeningToRemoteChanges();
  void initialize();
  void dispose();
}

class UserSyncManagerImpl implements UserSyncManager {
  final AuthenticationLocalDataSource _local;
  final AuthenticationRemoteDataSource _remote;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot>? _remoteSubscription;

  UserSyncManagerImpl(this._local, this._remote, this._firestore);

  @override
  void initialize() {
    startListeningToRemoteChanges();
  }

  @override
  void dispose() {
    stopListeningToRemoteChanges();
  }

  @override
  Future<void> syncData() async {
    await pushLocalChanges();
    await pullRemoteData();
  }

  @override
  Future<void> pushLocalChanges() async {
    final created = await _local.getCreatedUsers();
    for (final user in created) {
      try {
        await _remote.createUser(user);
        await _local.clearCreatedUser(user.id);
      } catch (e) {
        print('Error pushing creation for user ${user.id}: $e');
      }
    }

    final updated = await _local.getUpdatedUsers();
    for (final user in updated) {
      try {
        await _remote.updateUser(user);
        await _local.clearUpdatedUser(user.id);
      } catch (e) {
        print('Error pushing update for user ${user.id}: $e');
      }
    }

    final deleted = await _local.getDeletedUserIds();
    for (final id in deleted) {
      try {
        await _remote.deleteUser(id);
        await _local.clearDeletedUser(id);
      } catch (e) {
        print('Error pushing deletion for user $id: $e');
      }
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final uid = SessionManager.getUserSession()!.administratorId ??
        SessionManager.getUserSession()!.id;
    final remoteList = await _remote.getUsers(uid);
    for (final remoteUser in remoteList) {
      final localUser = await _local.getUserById(remoteUser.id);
      if (localUser == null) {
        await _local.applyCreate(remoteUser);
      } else if (remoteUser.updatedAt.isAfter(localUser.updatedAt)) {
        await _local.applyUpdate(remoteUser);
      }
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }

  @override
  Future<void> resetAccountPassword(String email) async {
    await _remote.resetPassword(email);
  }

  @override
  Future<void> renewEmailAccount(String email) async {
    await _remote.updateMailAddress(email);
  }

  @override
  void startListeningToRemoteChanges() {
    _remoteSubscription =
        _firestore.collection('users').snapshots().listen((snapshot) async {
      if (SessionManager.getUserSession() == null) return;
      final currentUserId = SessionManager.getUserSession()!.id;

      for (final change in snapshot.docChanges) {
        final userData = change.doc.data();
        if (userData == null) continue;

        if (userData['createdBy'] == currentUserId) continue;

        final remoteUser = UserModel.fromMap(userData);
        final localUser = await _local.getUserById(remoteUser.id);

        switch (change.type) {
          case DocumentChangeType.added:
            if (localUser == null) {
              await _local.applyCreate(remoteUser);
            }
            break;
          case DocumentChangeType.modified:
            if (localUser == null ||
                remoteUser.updatedAt.isAfter(localUser.updatedAt)) {
              await _local.applyUpdate(remoteUser);
            }
            break;
          case DocumentChangeType.removed:
            if (localUser != null) {
              await _local.applyDelete(remoteUser.id);
            }
            break;
        }
      }
    });
  }

  @override
  void stopListeningToRemoteChanges() {
    _remoteSubscription?.cancel();
    _remoteSubscription = null;
  }
}
