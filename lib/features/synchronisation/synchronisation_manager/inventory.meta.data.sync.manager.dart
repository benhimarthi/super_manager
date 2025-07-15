import '../../inventory_meta_data/data/data_source/inventory.meta.data.local.data.source.dart';
import '../../inventory_meta_data/data/data_source/inventory.meta.data.remote.data.source.dart';

abstract class InventoryMetadataSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
}

class InventoryMetadataSyncManagerImpl implements InventoryMetadataSyncManager {
  final InventoryMetadataLocalDataSource _local;
  final InventoryMetadataRemoteDataSource _remote;

  InventoryMetadataSyncManagerImpl(this._local, this._remote);

  @override
  Future<void> pushLocalChanges() async {
    final created = _local.getPendingCreates();
    final updated = _local.getPendingUpdates();
    final deleted = _local.getPendingDeletions();

    for (final metadata in created) {
      await _remote.createMetadata(metadata);
    }
    for (final metadata in updated) {
      await _remote.updateMetadata(metadata);
    }
    for (final id in deleted) {
      await _remote.deleteMetadata(id);
    }

    await _local.clearAll();
    for (final item in _local.getAllLocalMetadata()) {
      await _local.applyCreate(item);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllMetadata();
    await _local.clearAll();
    for (final metadata in remoteList) {
      await _local.applyCreate(metadata);
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }
}
