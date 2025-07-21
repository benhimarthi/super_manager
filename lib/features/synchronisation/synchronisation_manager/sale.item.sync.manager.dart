import '../../sale_item/data/data_sources/sale.item.local.data.source.dart';
import '../../sale_item/data/data_sources/sale.item.remote.data.source.dart';

abstract class SaleItemSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
}

class SaleItemSyncManagerImpl implements SaleItemSyncManager {
  final SaleItemLocalDataSource _local;
  final SaleItemRemoteDataSource _remote;

  SaleItemSyncManagerImpl(this._local, this._remote);

  @override
  Future<void> pushLocalChanges() async {
    final created = _local.getPendingCreates();
    final updated = _local.getPendingUpdates();
    final deleted = _local.getPendingDeletions();

    for (final item in created) {
      await _remote.createSaleItem(item);
    }
    for (final item in updated) {
      await _remote.updateSaleItem(item);
    }
    for (final id in deleted) {
      await _remote.deleteSaleItem(id);
    }

    await _local.clearAll();
    for (final item in _local.getAllLocalSaleItems()) {
      await _local.applyCreate(item);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    // For simplicity, pull all sale items (could be optimized by saleId)
    final remoteList = await _remote
        .getSaleItemsBySaleId(''); // or implement method to get all
    await _local.clearAll();
    for (final item in remoteList) {
      await _local.applyCreate(item);
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }
}
