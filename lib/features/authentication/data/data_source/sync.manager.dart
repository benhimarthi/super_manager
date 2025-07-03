import 'package:connectivity_plus/connectivity_plus.dart';
import 'authentication.local.data.source.dart';
import 'authentictaion.remote.data.source.dart';

class SyncManager {
  const SyncManager(this._remoteDataSource, this._localDataSource);

  final AuthenticationRemoteDataSource _remoteDataSource;
  final AuthenticationLocalDataSource _localDataSource;

  Future<void> syncData() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return; // No internet connection, skip sync
    }
    //await _syncPendingUserCreations();
    await _syncPendingUserUpdates();
    await _syncPendingUserDeletions();
  }

  Future<void> _syncPendingUserCreations() async {
    final pendingUsers = await _localDataSource.getCachedUsers();
    for (final user in pendingUsers) {
      if (await _localDataSource.isUserMarkedAsPending(user.id)) {
        await _remoteDataSource.createUser(user);
        await _localDataSource.clearPendingFlag(user.id);
      }
    }
  }

  Future<void> _syncPendingUserUpdates() async {
    try {
      final updatedUsers = await _localDataSource.getUpdatedUsers();
      print("Fetched updated users: $updatedUsers");
      for (final user in updatedUsers) {
        await _remoteDataSource.updateUser(user);
        await _localDataSource.clearUpdateFlag(user.id);
      }
    } catch (e, stack) {
      print("Error in _syncPendingUserUpdates: $e\n$stack");
    }
  }

  Future<void> _syncPendingUserDeletions() async {
    final deletedUsers = await _localDataSource.getDeletedUserIds();
    for (final userId in deletedUsers) {
      await _remoteDataSource.deleteUser(userId);
      await _localDataSource.clearDeletedFlag(userId);
    }
  }
}
