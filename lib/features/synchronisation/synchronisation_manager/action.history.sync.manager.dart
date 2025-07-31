import '../../action_history/data/data_source/action.history.local.data.source.dart';
import '../../action_history/data/data_source/action.history.remote.data.source.dart';

abstract class ActionHistorySyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
}

class ActionHistorySyncManagerImpl implements ActionHistorySyncManager {
  final ActionHistoryLocalDataSource _local;
  final ActionHistoryRemoteDataSource _remote;

  ActionHistorySyncManagerImpl(this._local, this._remote);

  @override
  Future<void> pushLocalChanges() async {
    final creates = _local.getPendingCreates();
    final deletions = _local.getPendingDeletions();

    for (final action in creates) {
      await _remote.createAction(action);
    }
    for (final del in deletions) {
      await _remote.deleteAction(
        del['entityId'],
        DateTime.parse(del['timestamp']),
      );
    }
    await _local.clearAll();
    for (final item in _local.getAllLocalActions()) {
      await _local.applyCreate(item);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllActions();
    await _local.clearAll();
    for (final action in remoteList) {
      await _local.applyCreate(action);
    }
  }

  @override
  Future<void> refreshFromRemote() async => pullRemoteData();
}
