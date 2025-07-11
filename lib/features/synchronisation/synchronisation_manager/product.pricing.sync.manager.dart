import '../../product_pricing/data/data_source/product.pricing.local.data.source.dart';
import '../../product_pricing/data/data_source/product.pricing.remote.data.source.dart';

abstract class ProductPricingSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote(); // optional login override
}

class ProductPricingSyncManagerImpl implements ProductPricingSyncManager {
  final ProductPricingLocalDataSource _local;
  final ProductPricingRemoteDataSource _remote;

  ProductPricingSyncManagerImpl(this._local, this._remote);

  @override
  Future<void> pushLocalChanges() async {
    final created = _local.getPendingCreates();
    final updated = _local.getPendingUpdates();
    final deleted = _local.getPendingDeletions();

    for (final pricing in created) {
      await _remote.createPricing(pricing);
    }
    for (final pricing in updated) {
      await _remote.updatePricing(pricing);
    }
    for (final id in deleted) {
      await _remote.deletePricing(id);
    }

    await _local.clearAll(); // clear queues only
    for (final item in _local.getAllLocalPricing()) {
      await _local.applyCreate(item); // rehydrate main cache
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllPricing();
    await _local.clearAll();
    for (final pricing in remoteList) {
      await _local.applyCreate(pricing);
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }
}
