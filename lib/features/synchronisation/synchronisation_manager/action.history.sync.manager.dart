import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/session/session.manager.dart';

import '../../action_history/data/data_source/action.history.local.data.source.dart';
import '../../action_history/data/data_source/action.history.remote.data.source.dart';
import '../../action_history/data/models/action.history.model.dart';

abstract class ActionHistorySyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
  void startListeningToRemoteChanges();
  void stopListeningToRemoteChanges();
  void initialize();
  void dispose();
}

class ActionHistorySyncManagerImpl implements ActionHistorySyncManager {
  final ActionHistoryLocalDataSource _local;
  final ActionHistoryRemoteDataSource _remote;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot>? _remoteSubscription;

  ActionHistorySyncManagerImpl(this._local, this._remote, this._firestore);

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
    for (final action in created) {
      try {
        await _remote.createAction(action);
        await _local.removeSyncedCreation(action.entityId, action.timestamp);
      } catch (e) {
        print(
            'Error pushing creation for action history ${action.entityId}-${action.timestamp}: $e');
      }
    }

    final deleted = _local.getPendingDeletions();
    for (final item in deleted) {
      final entityId = item['entityId'] as String;
      final timestamp = DateTime.parse(item['timestamp'] as String);
      try {
        await _remote.deleteAction(entityId, timestamp);
        await _local.removeSyncedDeletion(entityId, timestamp);
      } catch (e) {
        print(
            'Error pushing deletion for action history $entityId-$timestamp: $e');
      }
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllActions();
    for (final remoteAction in remoteList) {
      final localAction = await _local.getAction(
        remoteAction.entityId,
        remoteAction.timestamp,
      );
      if (localAction == null) {
        await _local.applyCreate(remoteAction);
      } else {
        // Action history is immutable so no update logic needed
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
        .collection('action_history')
        .snapshots()
        .listen((snapshot) async {
      if (SessionManager.getUserSession() == null) return;
      final currentUserId = SessionManager.getUserSession()!.id;

      for (final change in snapshot.docChanges) {
        final actionData = change.doc.data();
        if (actionData == null) continue;

        if (actionData['userId'] == currentUserId) continue;

        final remoteAction = ActionHistoryModel.fromMap(actionData);

        final localAction = await _local.getAction(
          remoteAction.entityId,
          remoteAction.timestamp,
        );

        switch (change.type) {
          case DocumentChangeType.added:
            if (localAction == null) {
              await _local.applyCreate(remoteAction);
            }
            break;
          case DocumentChangeType.removed:
            if (localAction != null) {
              await _local.applyDelete(
                remoteAction.entityId,
                remoteAction.timestamp,
              );
            }
            break;
          case DocumentChangeType.modified:
            // Action history is immutable, so no update logic
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
