import 'dart:async';

import '../../sale_item/data/data_sources/sale.item.local.data.source.dart';
import '../../sale_item/data/data_sources/sale.item.remote.data.source.dart';

abstract class SaleItemSyncManager {
  void initialize();
  void dispose();
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
}

class SaleItemSyncManagerImpl implements SaleItemSyncManager {
  final SaleItemLocalDataSource _local;
  final SaleItemRemoteDataSource _remote;
  StreamSubscription? _remoteSubscription;

  SaleItemSyncManagerImpl(this._local, this._remote);

  @override
  void initialize() {
    _remoteSubscription = _remote.watchAllSaleItems().listen((remoteSaleItems) async {
      final localSaleItems = await _local.getAllLocalSaleItems();
      for (final remoteSaleItem in remoteSaleItems) {
        final local = await _local.getSaleItemById(remoteSaleItem.id);
        if (local == null) {
          await _local.applyCreate(remoteSaleItem);
        } else if (remoteSaleItem.updatedAt.isAfter(local.updatedAt)) {
          await _local.applyUpdate(remoteSaleItem);
        }
      }
      for (final localSaleItem in localSaleItems) {
        if (!remoteSaleItems.any((remote) => remote.id == localSaleItem.id)) {
          await _local.applyDelete(localSaleItem.id);
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

    for (final saleItem in creations) {
      final remote = await _remote.createSaleItem(saleItem);
      await _local.removeSyncedCreation(saleItem.id);
      await _local.applyUpdate(remote); // To update with server-generated fields
    }
    for (final saleItem in updates) {
      await _remote.updateSaleItem(saleItem);
      await _local.removeSyncedUpdate(saleItem.id);
    }
    for (final id in deletions) {
      await _remote.deleteSaleItem(id);
      await _local.removeSyncedDeletion(id);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteSaleItems = await _remote.getAllSaleItems();
    final localSaleItems = await _local.getAllLocalSaleItems();

    for (final remoteSaleItem in remoteSaleItems) {
      final local = await _local.getSaleItemById(remoteSaleItem.id);
      if (local == null) {
        await _local.applyCreate(remoteSaleItem);
      } else if (remoteSaleItem.updatedAt.isAfter(local.updatedAt)) {
        await _local.applyUpdate(remoteSaleItem);
      }
    }

    for (final localSaleItem in localSaleItems) {
      if (!remoteSaleItems.any((remote) => remote.id == localSaleItem.id)) {
        await _local.applyDelete(localSaleItem.id);
      }
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await _local.clearAll();
    await pullRemoteData();
  }
}
