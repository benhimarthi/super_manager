import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/session/session.manager.dart';
import '../../product_pricing/data/data_source/product.pricing.local.data.source.dart';
import '../../product_pricing/data/data_source/product.pricing.remote.data.source.dart';
import '../../product_pricing/data/models/product.pricing.model.dart';

abstract class ProductPricingSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
  void startListeningToRemoteChanges();
  void stopListeningToRemoteChanges();
  void initialize();
  void dispose();
}

class ProductPricingSyncManagerImpl implements ProductPricingSyncManager {
  final ProductPricingLocalDataSource _local;
  final ProductPricingRemoteDataSource _remote;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot>? _remoteSubscription;

  ProductPricingSyncManagerImpl(this._local, this._remote, this._firestore);

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
    for (final pricing in created) {
      try {
        await _remote.createPricing(pricing);
        await _local.removeSyncedCreation(pricing.id);
      } catch (e) {
        print('Error pushing creation for product pricing ${pricing.id}: $e');
      }
    }

    final updated = await _local.getPendingUpdates();
    for (final pricing in updated) {
      try {
        await _remote.updatePricing(pricing);
        await _local.removeSyncedUpdate(pricing.id);
      } catch (e) {
        print('Error pushing update for product pricing ${pricing.id}: $e');
      }
    }

    final deleted = await _local.getPendingDeletions();
    for (final id in deleted) {
      try {
        await _remote.deletePricing(id);
        await _local.removeSyncedDeletion(id);
      } catch (e) {
        print('Error pushing deletion for product pricing $id: $e');
      }
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllPricing();
    for (final remotePricing in remoteList) {
      final localPricing = await _local.getProductPricingById(remotePricing.id);
      if (localPricing == null) {
        await _local.applyCreate(remotePricing);
      } else if (remotePricing.updatedAt.isAfter(localPricing.updatedAt)) {
        await _local.applyUpdate(remotePricing);
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
        .collection('product_pricings')
        .snapshots()
        .listen((snapshot) async {
      if (SessionManager.getUserSession() == null) return;
      final currentUserId = SessionManager.getUserSession()!.id;

      for (final change in snapshot.docChanges) {
        final pricingData = change.doc.data();
        if (pricingData == null) continue;

        if (pricingData['creatorID'] == currentUserId) continue;

        final remotePricing = ProductPricingModel.fromMap(pricingData);
        final localPricing = await _local.getProductPricingById(remotePricing.id);

        switch (change.type) {
          case DocumentChangeType.added:
            if (localPricing == null) {
              await _local.applyCreate(remotePricing);
            }
            break;
          case DocumentChangeType.modified:
            if (localPricing == null || remotePricing.updatedAt.isAfter(localPricing.updatedAt)) {
              await _local.applyUpdate(remotePricing);
            }
            break;
          case DocumentChangeType.removed:
            if (localPricing != null) {
              await _local.applyDelete(remotePricing.id);
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
