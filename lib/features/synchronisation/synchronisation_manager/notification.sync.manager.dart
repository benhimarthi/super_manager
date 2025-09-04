import '../../notification_manager/data/data_source/notification.local.data.source.dart';
import '../../notification_manager/data/data_source/notification.remote.data.source.dart';

abstract class NotificationSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
}

class NotificationSyncManagerImpl implements NotificationSyncManager {
  final NotificationLocalDataSource _local;
  final NotificationRemoteDataSource _remote;

  NotificationSyncManagerImpl(this._local, this._remote);

  @override
  Future<void> pushLocalChanges() async {
    final created = _local.getPendingCreates();
    final updated = _local.getPendingUpdates();
    final deleted = _local.getPendingDeletions();

    for (final notification in created) {
      await _remote.createNotification(notification);
    }
    for (final notification in updated) {
      await _remote.updateNotification(notification);
    }
    for (final id in deleted) {
      await _remote.deleteNotification(id);
    }

    await _local.clearAll();
    for (final n in _local.getAllLocalNotifications()) {
      await _local.applyCreate(n);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllNotifications();
    await _local.clearAll();
    for (final n in remoteList) {
      await _local.applyCreate(n);
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }
}
