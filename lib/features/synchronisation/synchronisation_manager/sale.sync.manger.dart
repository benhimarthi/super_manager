import '../../sale/data/data_source/sale.local.data.source.dart';
import '../../sale/data/data_source/sale.remote.data.source.dart';

abstract class SaleSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
}

class SaleSyncManagerImpl implements SaleSyncManager {
  final SaleLocalDataSource _local;
  final SaleRemoteDataSource _remote;

  SaleSyncManagerImpl(this._local, this._remote);

  @override
  Future<void> pushLocalChanges() async {
    final created = _local.getPendingCreates();
    final updated = _local.getPendingUpdates();
    final deleted = _local.getPendingDeletions();

    for (final sale in created) {
      await _remote.createSale(sale);
    }
    for (final sale in updated) {
      await _remote.updateSale(sale);
    }
    for (final id in deleted) {
      await _remote.deleteSale(id);
    }

    await _local.clearAll();
    for (final item in _local.getAllLocalSales()) {
      await _local.applyCreate(item);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllSales();
    await _local.clearAll();
    for (final sale in remoteList) {
      await _local.applyCreate(sale);
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }
}
