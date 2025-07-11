import '../../product/data/data_sources/product.local.data.source.dart';
import '../../product/data/data_sources/product.remote.data.source.dart';

abstract class ProductSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote(); // optional full overwrite
}

class ProductSyncManagerImpl implements ProductSyncManager {
  final ProductLocalDataSource _local;
  final ProductRemoteDataSource _remote;

  ProductSyncManagerImpl(this._local, this._remote);

  @override
  Future<void> pushLocalChanges() async {
    final created = await _local.getPendingCreations();
    final updated = await _local.getPendingUpdates();
    final deleted = await _local.getPendingDeletions();

    for (final product in created) {
      await _remote.createProduct(product);
    }
    for (final product in updated) {
      await _remote.updateProduct(product);
    }
    for (final id in deleted) {
      await _remote.deleteProduct(id);
    }

    await _local.clearSyncedCreations();
    await _local.clearSyncedUpdates();
    for (final id in deleted) {
      await _local.removeSyncedDeletion(id);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllProducts();

    await _local.clearAll();
    for (final product in remoteList) {
      await _local.applyCreate(product);
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }
}
