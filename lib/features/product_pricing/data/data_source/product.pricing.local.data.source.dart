import 'package:hive/hive.dart';

import '../../../../core/errors/custom.exception.dart';
import '../models/product.pricing.model.dart';

abstract class ProductPricingLocalDataSource {
  Future<void> addCreatedProductPricing(ProductPricingModel pricing);
  Future<void> addUpdatedProductPricing(ProductPricingModel pricing);
  Future<void> addDeletedProductPricingId(String id);

  Future<void> applyCreate(ProductPricingModel pricing);
  Future<void> applyUpdate(ProductPricingModel pricing);
  Future<void> applyDelete(String id);

  Future<List<ProductPricingModel>> getAllLocalProductPricings();
  Future<ProductPricingModel?> getProductPricingById(String id);

  Future<List<ProductPricingModel>> getPendingCreations();
  Future<List<ProductPricingModel>> getPendingUpdates();
  Future<List<String>> getPendingDeletions();

  Future<void> removeSyncedCreation(String id);
  Future<void> removeSyncedUpdate(String id);
  Future<void> removeSyncedDeletion(String id);

  Future<void> clearAll();
}

class ProductPricingLocalDataSourceImpl
    implements ProductPricingLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _updatedBox;
  final Box _deletedBox;

  ProductPricingLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box updatedBox,
    required Box deletedBox,
  })  : _mainBox = mainBox,
        _createdBox = createdBox,
        _updatedBox = updatedBox,
        _deletedBox = deletedBox;

  @override
  Future<void> addCreatedProductPricing(ProductPricingModel pricing) async {
    try {
      await applyCreate(pricing);
      await _createdBox.put(pricing.id, pricing.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to add pending created product pricing',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> addUpdatedProductPricing(ProductPricingModel pricing) async {
    try {
      await applyUpdate(pricing);
      await _updatedBox.put(pricing.id, pricing.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to add pending updated product pricing',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> addDeletedProductPricingId(String id) async {
    try {
      await applyDelete(id);
      await _deletedBox.put(id, true);
    } catch (_) {
      throw const LocalException(
        message: 'Failed to add pending deleted product pricing',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> applyCreate(ProductPricingModel pricing) async {
    try {
      await _mainBox.put(pricing.id, pricing.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to apply local product pricing creation',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> applyUpdate(ProductPricingModel pricing) async {
    try {
      await _mainBox.put(pricing.id, pricing.toMap());
    } catch (_) {
      throw const LocalException(
        message: 'Failed to apply local product pricing update',
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
        message: 'Failed to apply local product pricing deletion',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ProductPricingModel>> getAllLocalProductPricings() async {
    try {
      return _mainBox.values
          .toList()
          .map((e) => ProductPricingModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load local product pricing list',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ProductPricingModel?> getProductPricingById(String id) async {
    try {
      final raw = _mainBox.get(id);
      if (raw == null) {
        return null;
      }
      return ProductPricingModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load local product pricing',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ProductPricingModel>> getPendingCreations() async {
    try {
      return _createdBox.values
          .map((e) => ProductPricingModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      throw const LocalException(
        message: 'Failed to load created queue',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ProductPricingModel>> getPendingUpdates() async {
    try {
      return _updatedBox.values
          .map((e) => ProductPricingModel.fromMap(Map<String, dynamic>.from(e)))
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
  Future<void> removeSyncedCreation(String id) async {
    try {
      await _createdBox.delete(id);
    } catch (_) {
      throw const LocalException(
        message: 'Failed to remove created ID from queue',
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
        message: 'Failed to remove updated ID from queue',
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
