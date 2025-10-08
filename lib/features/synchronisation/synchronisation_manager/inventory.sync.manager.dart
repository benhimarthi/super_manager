import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Inventory/data/data_sources/inventory.local.data.source.dart';
import '../../Inventory/data/data_sources/inventory.remote.data.source.dart';
import '../../Inventory/data/models/inventory.model.dart';

abstract class InventorySyncManager {
  Future<void> startSync();
  void stopSync();
  Future<void> pullRemoteData();
}

class InventorySyncManagerImpl implements InventorySyncManager {
  final InventoryLocalDataSource _local;
  final InventoryRemoteDataSource _remote;
  final FirebaseFirestore _firestore;

  StreamSubscription<QuerySnapshot>? _subscription;

  InventorySyncManagerImpl(this._local, this._remote, this._firestore);

  @override
  Future<void> startSync() async {
    await _pushLocalChanges();
    _subscription = _remote.streamInventory().listen((snapshot) {
      for (final docChange in snapshot.docChanges) {
        final remoteModel =
            InventoryModel.fromMap(docChange.doc.data() as Map<String, dynamic>);
        if (docChange.type == DocumentChangeType.added) {
          _handleRemoteAdd(remoteModel);
        } else if (docChange.type == DocumentChangeType.modified) {
          _handleRemoteUpdate(remoteModel);
        } else if (docChange.type == DocumentChangeType.removed) {
          _handleRemoteDelete(remoteModel.id);
        }
      }
    });
  }

  @override
  void stopSync() {
    _subscription?.cancel();
  }

  @override
  Future<void> pullRemoteData() async {
    await _local.clearAll();
    final remoteItems = await _remote.getAllInventory();
    for (final item in remoteItems) {
      await _local.applyCreate(item);
    }
  }

  Future<void> _pushLocalChanges() async {
    final pendingCreates = _local.getPendingCreates();
    final pendingUpdates = _local.getPendingUpdates();
    final pendingDeletes = _local.getPendingDeletions();

    for (final model in pendingCreates) {
      await _remote.createInventory(model);
      await _local.removeSyncedCreation(model.id);
    }
    for (final model in pendingUpdates) {
      await _remote.updateInventory(model);
      await _local.removeSyncedUpdate(model.id);
    }
    for (final id in pendingDeletes) {
      await _remote.deleteInventory(id);
      await _local.removeSyncedDeletion(id);
    }
  }

  Future<void> _handleRemoteAdd(InventoryModel remoteModel) async {
    final localModel = await _local.getInventoryById(remoteModel.id);
    if (localModel == null) {
      await _local.applyCreate(remoteModel);
    } else {
      // Conflict: remote add, local exists. Merge or choose one.
      // For simplicity, we'll assume the remote one is newer.
      await _local.applyUpdate(remoteModel);
    }
  }

  Future<void> _handleRemoteUpdate(InventoryModel remoteModel) async {
    final localModel = await _local.getInventoryById(remoteModel.id);
    if (localModel == null ||
        remoteModel.updatedAt.isAfter(localModel.updatedAt)) {
      await _local.applyUpdate(remoteModel);
    }
  }

  Future<void> _handleRemoteDelete(String id) async {
    await _local.applyDelete(id);
  }
}
