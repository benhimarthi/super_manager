import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/session/session.manager.dart';

import '../../product_category/data/data_sources/product.category.local.data.source.dart';
import '../../product_category/data/data_sources/product.category.remote.data.source.dart';
import '../../product_category/data/models/product.category.model.dart';

abstract class ProductCategorySyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
  void startListeningToRemoteChanges();
  void stopListeningToRemoteChanges();
  void initialize();
  void dispose();
}

class ProductCategorySyncManagerImpl implements ProductCategorySyncManager {
  final ProductCategoryLocalDataSource _local;
  final ProductCategoryRemoteDataSource _remote;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot>? _remoteSubscription;

  ProductCategorySyncManagerImpl(this._local, this._remote, this._firestore);

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
    for (final category in created) {
      try {
        await _remote.createCategory(category);
        await _local.removeSyncedCreation(category.id);
      } catch (e) {
        print('Error pushing creation for category ${category.id}: $e');
      }
    }

    final updated = await _local.getPendingUpdates();
    for (final category in updated) {
      try {
        await _remote.updateCategory(category);
        await _local.removeSyncedUpdate(category.id);
      } catch (e) {
        print('Error pushing update for category ${category.id}: $e');
      }
    }

    final deleted = await _local.getPendingDeletions();
    for (final id in deleted) {
      try {
        await _remote.deleteCategory(id);
        await _local.removeSyncedDeletion(id);
      } catch (e) {
        print('Error pushing deletion for category $id: $e');
      }
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.getAllCategories();
    for (final remoteCategory in remoteList) {
      final localCategory = await _local.getCategoryById(remoteCategory.id);
      if (localCategory == null) {
        await _local.applyCreate(remoteCategory);
      } else if (remoteCategory.updatedAt.isAfter(localCategory.updatedAt)) {
        await _local.applyUpdate(remoteCategory);
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
        .collection('product_categories')
        .snapshots()
        .listen((snapshot) async {
      if (SessionManager.getUserSession() == null) return;
      final currentUserId = SessionManager.getUserSession()!.id;

      for (final change in snapshot.docChanges) {
        final categoryData = change.doc.data();
        if (categoryData == null) continue;

        // Assuming 'adminId' is the field that stores the creator's ID
        if (categoryData['adminId'] == currentUserId) continue;

        final remoteCategory = ProductCategoryModel.fromMap(categoryData as Map<String, dynamic>);
        final localCategory = await _local.getCategoryById(remoteCategory.id);

        switch (change.type) {
          case DocumentChangeType.added:
            if (localCategory == null) {
              await _local.applyCreate(remoteCategory);
            }
            break;
          case DocumentChangeType.modified:
            if (localCategory == null || remoteCategory.updatedAt.isAfter(localCategory.updatedAt)) {
              await _local.applyUpdate(remoteCategory);
            }
            break;
          case DocumentChangeType.removed:
            if (localCategory != null) {
              await _local.applyDelete(remoteCategory.id);
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
