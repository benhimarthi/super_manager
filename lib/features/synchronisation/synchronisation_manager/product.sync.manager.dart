import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/session/session.manager.dart';

import '../../product/data/data_sources/product.local.data.source.dart';
import '../../product/data/data_sources/product.remote.data.source.dart';
import '../../product/data/models/product.model.dart';

abstract class ProductSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
  void startListeningToRemoteChanges();
  void stopListeningToRemoteChanges();
  void initialize();
  void dispose();
}

class ProductSyncManagerImpl implements ProductSyncManager {
  final ProductLocalDataSource _local;
  final ProductRemoteDataSource _remote;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot>? _remoteSubscription;

  ProductSyncManagerImpl(this._local, this._remote, this._firestore);

  @override
  void initialize() {
    startListeningToRemoteChanges();
  }

  @override
  void dispose() {
    stopListeningToRemoteChanges();
  }

  @override
  Future<void> pushLocalChanges() async {
    final created = await _local.getPendingCreations();
    for (final product in created) {
      try {
        await _remote.createProduct(product);
        await _local.removeSyncedCreation(product.id);
      } catch (e) {
        print('Error pushing creation for product ${product.id}: $e');
      }
    }

    final updated = await _local.getPendingUpdates();
    for (final product in updated) {
      try {
        await _remote.updateProduct(product);
        await _local.removeSyncedUpdate(product.id);
      } catch (e) {
        print('Error pushing update for product ${product.id}: $e');
      }
    }

    final deleted = await _local.getPendingDeletions();
    for (final id in deleted) {
      try {
        await _remote.deleteProduct(id);
        await _local.removeSyncedDeletion(id);
      } catch (e) {
        print('Error pushing deletion for product $id: $e');
      }
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllProducts();
    for (final remoteProduct in remoteList) {
      final localProduct = await _local.getProductById(remoteProduct.id);
      if (localProduct == null) {
        await _local.applyCreate(remoteProduct);
      } else if (remoteProduct.updatedAt.isAfter(localProduct.updatedAt)) {
        await _local.applyUpdate(remoteProduct);
      }
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }

  @override
  void startListeningToRemoteChanges() {
    _remoteSubscription = _firestore
        .collection('products')
        .snapshots()
        .listen((snapshot) async {
      if (SessionManager.getUserSession() == null) return;
      final currentUserId = SessionManager.getUserSession()!.id;

      for (final change in snapshot.docChanges) {
        final productData = change.doc.data();
        if (productData == null) continue;

        if (productData['creatorID'] == currentUserId) continue;

        final remoteProduct = ProductModel.fromMap(productData);
        final localProduct = await _local.getProductById(remoteProduct.id);

        switch (change.type) {
          case DocumentChangeType.added:
            if (localProduct == null) {
              await _local.applyCreate(remoteProduct);
            }
            break;
          case DocumentChangeType.modified:
            if (localProduct == null || remoteProduct.updatedAt.isAfter(localProduct.updatedAt)) {
              await _local.applyUpdate(remoteProduct);
            }
            break;
          case DocumentChangeType.removed:
            if (localProduct != null) {
              await _local.applyDelete(remoteProduct.id);
            }
            break;
        }
      }
    });
  }

  @override
  void stopListeningToRemoteChanges() {
    _remoteSubscription?.cancel();
    _remoteSubscription = null;
  }
}
