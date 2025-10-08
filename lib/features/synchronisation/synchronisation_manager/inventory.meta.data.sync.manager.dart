import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/features/inventory_meta_data/data/models/inventory.meta.data.model.dart';

import '../../inventory_meta_data/data/data_source/inventory.meta.data.local.data.source.dart';
import '../../inventory_meta_data/data/data_source/inventory.meta.data.remote.data.source.dart';

abstract class InventoryMetadataSyncManager {
  Future<void> startSync();
  void stopSync();
  Future<void> pullRemoteData();
}

class InventoryMetadataSyncManagerImpl implements InventoryMetadataSyncManager {
  final InventoryMetadataLocalDataSource _local;
  final InventoryMetadataRemoteDataSource _remote;

  StreamSubscription<QuerySnapshot>? _subscription;

  InventoryMetadataSyncManagerImpl(this._local, this._remote);

  @override
  Future<void> startSync() async {
    await _pushLocalChanges();
    _subscription = _remote.streamInventoryMetadata().listen((snapshot) {
      for (final docChange in snapshot.docChanges) {
        final remoteModel = InventoryMetadataModel.fromMap(
          docChange.doc.data() as Map<String, dynamic>,
        );
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
    final remoteItems = await _remote.getAllMetadata();
    for (final item in remoteItems) {
      await _local.applyCreate(item);
    }
  }

  Future<void> _pushLocalChanges() async {
    final pendingCreates = _local.getPendingCreates();
    final pendingUpdates = _local.getPendingUpdates();
    final pendingDeletes = _local.getPendingDeletions();

    print(pendingCreates);
    for (final model in pendingCreates) {
      await _remote.createMetadata(model);
      await _local.removeSyncedCreation(model.id);
    }
    for (final model in pendingUpdates) {
      await _remote.updateMetadata(model);
      await _local.removeSyncedUpdate(model.id);
    }
    for (final id in pendingDeletes) {
      await _remote.deleteMetadata(id);
      await _local.removeSyncedDeletion(id);
    }
  }

  Future<void> _handleRemoteAdd(InventoryMetadataModel remoteModel) async {
    final localModel = await _local.getMetadataById(remoteModel.id);
    if (localModel == null) {
      await _local.applyCreate(remoteModel);
    } else {
      // Conflict: remote add, local exists. Merge or choose one.
      // For simplicity, we'll assume the remote one is newer.
      await _local.applyUpdate(remoteModel);
    }
  }

  Future<void> _handleRemoteUpdate(InventoryMetadataModel remoteModel) async {
    final localModel = await _local.getMetadataById(remoteModel.id);
    if (localModel == null ||
        remoteModel.updatedAt.isAfter(localModel.updatedAt)) {
      await _local.applyUpdate(remoteModel);
    }
  }

  Future<void> _handleRemoteDelete(String id) async {
    await _local.applyDelete(id);
  }
}
