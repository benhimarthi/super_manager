import '../../Inventory/data/data_sources/inventory.local.data.source.dart';
import '../../Inventory/data/data_sources/inventory.remote.data.source.dart';

abstract class InventorySyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
}

class InventorySyncManagerImpl implements InventorySyncManager {
  final InventoryLocalDataSource _local;
  final InventoryRemoteDataSource _remote;

  InventorySyncManagerImpl(this._local, this._remote);

  @override
  Future<void> pushLocalChanges() async {
    final created = _local.getPendingCreates();
    final updated = _local.getPendingUpdates();
    final deleted = _local.getPendingDeletions();

    for (final inventory in created) {
      await _remote.createInventory(inventory);
    }
    for (final inventory in updated) {
      await _remote.updateInventory(inventory);
    }
    for (final id in deleted) {
      await _remote.deleteInventory(id);
    }

    await _local.clearAll();
    for (final item in _local.getAllLocalInventory()) {
      await _local.applyCreate(item);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllInventory();
    await _local.clearAll();
    for (final inventory in remoteList) {
      await _local.applyCreate(inventory);
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }
}
