import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/session.manager.dart';
import '../../notification_manager/data/data_source/notification.local.data.source.dart';
import '../../notification_manager/data/data_source/notification.remote.data.source.dart';
import '../../notification_manager/data/models/notification.model.dart';

abstract class NotificationSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
  void startListeningToRemoteChanges();
  void stopListeningToRemoteChanges();
  void initialize();
  void dispose();
}

class NotificationSyncManagerImpl implements NotificationSyncManager {
  final NotificationLocalDataSource _local;
  final NotificationRemoteDataSource _remote;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot>? _remoteSubscription;

  NotificationSyncManagerImpl(this._local, this._remote, this._firestore);

  @override
  void initialize() {
    startListeningToRemoteChanges();
  }

  @override
  void dispose() {
    stopListeningToRemoteChanges();
  }

  @override
  Future<void> pushLocalChanges() async {
    final created = _local.getPendingCreates();
    for (final notification in created) {
      try {
        await _remote.createNotification(notification);
        await _local.removeSyncedCreation(notification.id);
      } catch (e) {
        print('Error pushing creation for notification ${notification.id}: $e');
      }
    }

    final updated = _local.getPendingUpdates();
    for (final notification in updated) {
      try {
        await _remote.updateNotification(notification);
        await _local.removeSyncedUpdate(notification.id);
      } catch (e) {
        print('Error pushing update for notification ${notification.id}: $e');
      }
    }

    final deleted = _local.getPendingDeletions();
    for (final id in deleted) {
      try {
        await _remote.deleteNotification(id);
        await _local.removeSyncedDeletion(id);
      } catch (e) {
        print('Error pushing deletion for notification $id: $e');
      }
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllNotifications();
    for (final remoteNotification in remoteList) {
      final localNotification = await _local.getNotificationById(remoteNotification.id);
      if (localNotification == null) {
        await _local.applyCreate(remoteNotification);
      } else if (remoteNotification.updatedAt.isAfter(localNotification.updatedAt)) {
        await _local.applyUpdate(remoteNotification);
      }
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }

  @override
  void startListeningToRemoteChanges() {
    _remoteSubscription = _firestore
        .collection('notifications')
        .snapshots()
        .listen((snapshot) async {
      if (SessionManager.getUserSession() == null) return;
      final currentUserId = SessionManager.getUserSession()!.id;

      for (final change in snapshot.docChanges) {
        final notificationData = change.doc.data();
        if (notificationData == null) continue;

        if (notificationData['creatorID'] == currentUserId) continue;

        final remoteNotification = NotificationModel.fromMap(notificationData as Map<String, dynamic>);
        final localNotification = await _local.getNotificationById(remoteNotification.id);

        switch (change.type) {
          case DocumentChangeType.added:
            if (localNotification == null) {
              await _local.applyCreate(remoteNotification);
            }
            break;
          case DocumentChangeType.modified:
            if (localNotification == null || remoteNotification.updatedAt.isAfter(localNotification.updatedAt)) {
              await _local.applyUpdate(remoteNotification);
            }
            break;
          case DocumentChangeType.removed:
            if (localNotification != null) {
              await _local.applyDelete(remoteNotification.id);
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
