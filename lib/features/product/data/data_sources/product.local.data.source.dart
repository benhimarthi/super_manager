import 'package:hive/hive.dart';
import 'package:super_manager/core/session/session.manager.dart';

import '../../../../core/errors/custom.exception.dart';
import '../models/product.model.dart';

abstract class ProductLocalDataSource {
  Future<void> addCreatedProduct(ProductModel product);
  Future<void> addUpdatedProduct(ProductModel product);
  Future<void> addDeletedProductId(String id);

  Future<void> applyCreate(ProductModel product);
  Future<void> applyUpdate(ProductModel product);
  Future<void> applyDelete(String id);

  Future<List<ProductModel>> getAllLocalProducts();
  Future<ProductModel> getLocalProductById(String id);

  Future<List<ProductModel>> getPendingCreations();
  Future<List<ProductModel>> getPendingUpdates();
  Future<List<String>> getPendingDeletions();

  Future<void> clearSyncedCreations();
  Future<void> clearSyncedUpdates();
  Future<void> removeSyncedDeletion(String id);

  Future<void> clearAll();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _updatedBox;
  final Box _deletedBox;

  ProductLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box updatedBox,
    required Box deletedBox,
  }) : _mainBox = mainBox,
       _createdBox = createdBox,
       _updatedBox = updatedBox,
       _deletedBox = deletedBox;

  @override
  Future<void> addCreatedProduct(ProductModel product) async {
    try {
      await applyCreate(product);
      await _createdBox.put(product.id, product.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to add pending created product',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> addUpdatedProduct(ProductModel product) async {
    try {
      await applyUpdate(product);
      await _updatedBox.put(product.id, product.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to add pending updated product',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> addDeletedProductId(String id) async {
    try {
      await applyDelete(id);
      await _deletedBox.put(id, true);
    } catch (_) {
      throw const LocalException(
        message: 'Failed to add pending deleted product',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> applyCreate(ProductModel product) async {
    try {
      await _mainBox.put(product.id, product.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to apply local product creation',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> applyUpdate(ProductModel product) async {
    try {
      await _mainBox.put(product.id, product.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to apply local product update',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> applyDelete(String id) async {
    try {
      await _mainBox.delete(id);
    } catch (_) {
      throw const LocalException(
        message: 'Failed to apply local product deletion',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ProductModel>> getAllLocalProducts() async {
    try {
      for (var t in _mainBox.values) {
        print("8888888888888888888888888888889999990000 ${t['name']}");
      }
      return _mainBox.values
          .toList()
          .map((e) => ProductModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load local product list',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ProductModel> getLocalProductById(String id) async {
    try {
      final raw = _mainBox.get(id);
      if (raw == null) {
        throw const LocalException(
          message: 'Product not found in cache',
          statusCode: 500,
        );
      }
      return ProductModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load local product',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ProductModel>> getPendingCreations() async {
    try {
      return _createdBox.values
          .map((e) => ProductModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load created queue',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ProductModel>> getPendingUpdates() async {
    try {
      return _updatedBox.values
          .map((e) => ProductModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load updated queue',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<String>> getPendingDeletions() async {
    try {
      return _deletedBox.keys.map((e) => e.toString()).toList();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load deleted queue',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> clearSyncedCreations() async {
    try {
      await _createdBox.clear();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to clear created queue',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> clearSyncedUpdates() async {
    try {
      await _updatedBox.clear();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to clear updated queue',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> removeSyncedDeletion(String id) async {
    try {
      await _deletedBox.delete(id);
    } catch (_) {
      throw const LocalException(
        message: 'Failed to remove deleted ID from queue',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> clearAll() async {
    await _mainBox.clear();
    await _createdBox.clear();
    await _updatedBox.clear();
    await _deletedBox.clear();
  }
}
