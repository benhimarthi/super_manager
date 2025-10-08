import 'dart:async';

import '../../sale/data/data_source/sale.local.data.source.dart';
import '../../sale/data/data_source/sale.remote.data.source.dart';

abstract class SaleSyncManager {
  void initialize();
  void dispose();
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
}

class SaleSyncManagerImpl implements SaleSyncManager {
  final SaleLocalDataSource _local;
  final SaleRemoteDataSource _remote;
  StreamSubscription? _remoteSubscription;

  SaleSyncManagerImpl(this._local, this._remote);

  @override
  void initialize() {
    _remoteSubscription = _remote.watchAllSales().listen((remoteSales) async {
      final localSales = await _local.getAllLocalSales();
      for (final remoteSale in remoteSales) {
        final local = await _local.getSaleById(remoteSale.id);
        if (local == null) {
          await _local.applyCreate(remoteSale);
        } else if (remoteSale.updatedAt.isAfter(local.updatedAt)) {
          await _local.applyUpdate(remoteSale);
        }
      }
      for (final localSale in localSales) {
        if (!remoteSales.any((remote) => remote.id == localSale.id)) {
          await _local.applyDelete(localSale.id);
        }
      }
    });
  }

  @override
  void dispose() {
    _remoteSubscription?.cancel();
  }

  @override
  Future<void> pushLocalChanges() async {
    final creations = await _local.getPendingCreates();
    final updates = await _local.getPendingUpdates();
    final deletions = await _local.getPendingDeletions();

    for (final sale in creations) {
      final remote = await _remote.createSale(sale);
      await _local.removeSyncedCreation(sale.id);
      await _local.applyUpdate(remote); // To update with server-generated fields
    }
    for (final sale in updates) {
      await _remote.updateSale(sale);
      await _local.removeSyncedUpdate(sale.id);
    }
    for (final id in deletions) {
      await _remote.deleteSale(id);
      await _local.removeSyncedDeletion(id);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteSales = await _remote.getAllSales();
    final localSales = await _local.getAllLocalSales();

    for (final remoteSale in remoteSales) {
      final local = await _local.getSaleById(remoteSale.id);
      if (local == null) {
        await _local.applyCreate(remoteSale);
      } else if (remoteSale.updatedAt.isAfter(local.updatedAt)) {
        await _local.applyUpdate(remoteSale);
      }
    }

    for (final localSale in localSales) {
      if (!remoteSales.any((remote) => remote.id == localSale.id)) {
        await _local.applyDelete(localSale.id);
      }
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await _local.clearAll();
    await pullRemoteData();
  }
}
