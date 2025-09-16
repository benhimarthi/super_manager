import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/session/session.manager.dart';

import '../../product/data/data_sources/product.local.data.source.dart';
import '../../product/data/data_sources/product.remote.data.source.dart';
import '../../product/data/models/product.model.dart';

abstract class ProductSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote(); // optional full overwrite
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
    // Call this once after creation or when app starts
    startListeningToRemoteChanges();
  }

  @override
  void dispose() {
    // Call this on app shutdown or when sync manager no longer needed
    stopListeningToRemoteChanges();
  }

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

  @override
  void startListeningToRemoteChanges() {
    print("@@@@@@@@@@@@@@@@##########555555555555555555555");
    _remoteSubscription = _firestore
        .collection('products') //products
        .snapshots()
        .listen(
          (snapshot) async {
            for (final change in snapshot.docChanges) {
              if (SessionManager.getUserSession() == null) continue;
              final currentUserId = SessionManager.getUserSession()!.id;
              final adminID = SessionManager.getUserSession()!.administratorId;
              final myProducts = await _local.getAllLocalProducts();
              final productData = change.doc.data();

              if (productData == null) {
                continue;
              } /*else if (productData['adminId'] == adminID) {
                final productIds = myProducts.map((x) => x.id).toList();
                if (productIds.isNotEmpty) {
                  if (productIds.contains(productData['id'])) {
                    continue;
                  }
                }
              }*/
              switch (change.type) {
                case DocumentChangeType.added:
                  // Only apply remote create if not pending local creations
                  if (currentUserId != productData['creatorID']) {
                    final remoteProduct = ProductModel.fromMap(productData);
                    await _local.applyCreate(remoteProduct);
                  }
                  break;
                case DocumentChangeType.modified:
                  // Only apply remote update if not pending local updates
                  if (currentUserId != productData['creatorID']) {
                    final remoteProduct = ProductModel.fromMap(productData);
                    print("999999999@@@@@@@@@@@@@@@@66666666666666");
                    await _local.applyUpdate(remoteProduct);
                  }
                  break;
                case DocumentChangeType.removed:
                  // Only apply remote delete if not pending local deletes
                  if (currentUserId != productData['creatorID']) {
                    await _local.applyDelete(productData['id']);
                  }
                  break;
              }
            }
          },
          onError: (error) {
            print('Error syncing products in real-time: $error');
          },
        );
  }

  /// Stop listening to remote changes
  @override
  void stopListeningToRemoteChanges() {
    _remoteSubscription?.cancel();
    _remoteSubscription = null;
  }
}
