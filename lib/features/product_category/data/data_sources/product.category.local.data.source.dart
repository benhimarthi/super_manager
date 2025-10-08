import 'package:hive/hive.dart';
import '../../../../core/errors/custom.exception.dart';
import '../models/product.category.model.dart';

abstract class ProductCategoryLocalDataSource {
  Future<void> addCreatedCategory(ProductCategoryModel category);
  Future<void> addUpdatedCategory(ProductCategoryModel category);
  Future<void> addDeletedCategoryId(String id);

  Future<List<ProductCategoryModel>> getAllLocalCategories();
  Future<ProductCategoryModel?> getCategoryById(String id);

  Future<void> applyCreate(ProductCategoryModel category);
  Future<void> applyUpdate(ProductCategoryModel category);
  Future<void> applyDelete(String id);

  Future<List<ProductCategoryModel>> getPendingCreations();
  Future<List<ProductCategoryModel>> getPendingUpdates();
  Future<List<String>> getPendingDeletions();

  Future<void> clearSyncedCreations();
  Future<void> clearSyncedUpdates();
  Future<void> removeSyncedCreation(String id);
  Future<void> removeSyncedUpdate(String id);
  Future<void> removeSyncedDeletion(String id);
  Future<void> clearAll();
}

class ProductCategoryLocalDataSourceImpl
    implements ProductCategoryLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _updatedBox;
  final Box _deletedBox;

  ProductCategoryLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box updatedBox,
    required Box deletedBox,
  }) : _mainBox = mainBox,
       _createdBox = createdBox,
       _updatedBox = updatedBox,
       _deletedBox = deletedBox;

  @override
  Future<void> addCreatedCategory(ProductCategoryModel category) async {
    try {
      await _createdBox.put(category.id, category.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to add pending created category',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> addUpdatedCategory(ProductCategoryModel category) async {
    try {
      await _updatedBox.put(category.id, category.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to add pending updated category',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> addDeletedCategoryId(String id) async {
    try {
      await _deletedBox.put(id, true);
    } catch (_) {
      throw const LocalException(
        message: 'Failed to add pending deleted category',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> applyCreate(ProductCategoryModel category) async {
    try {
      await _mainBox.put(category.id, category.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to apply local category creation',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> applyUpdate(ProductCategoryModel category) async {
    try {
      await _mainBox.put(category.id, category.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to apply local category update',
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
        message: 'Failed to apply local category deletion',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ProductCategoryModel>> getAllLocalCategories() async {
    try {
      return _mainBox.values
          .map(
            (e) => ProductCategoryModel.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load local category list',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ProductCategoryModel?> getCategoryById(String id) async {
    try {
      final raw = _mainBox.get(id);
      if (raw == null) {
        return null;
      }
      return ProductCategoryModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load local category',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ProductCategoryModel>> getPendingCreations() async {
    try {
      return _createdBox.values
          .map(
            (e) => ProductCategoryModel.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load created queue',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ProductCategoryModel>> getPendingUpdates() async {
    try {
      return _updatedBox.values
          .map(
            (e) => ProductCategoryModel.fromMap(Map<String, dynamic>.from(e)),
          )
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
  Future<void> removeSyncedCreation(String id) async {
    try {
      await _createdBox.delete(id);
    } catch (_) {
      throw const LocalException(
        message: 'Failed to remove created from queue',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> removeSyncedUpdate(String id) async {
    try {
      await _updatedBox.delete(id);
    } catch (_) {
      throw const LocalException(
        message: 'Failed to remove updated from queue',
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
