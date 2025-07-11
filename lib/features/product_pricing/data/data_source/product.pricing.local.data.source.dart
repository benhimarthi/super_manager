import 'package:hive/hive.dart';
import 'package:super_manager/core/errors/custom.exception.dart';
import 'package:super_manager/core/session/session.manager.dart';

import '../models/product.pricing.model.dart';

abstract class ProductPricingLocalDataSource {
  Future<void> addCreatedPricing(ProductPricingModel model);
  Future<void> addUpdatedPricing(ProductPricingModel model);
  Future<void> addDeletedPricingId(String id);

  Future<void> applyCreate(ProductPricingModel model);
  Future<void> applyUpdate(ProductPricingModel model);
  Future<void> applyDelete(String id);

  List<ProductPricingModel> getAllLocalPricing();

  List<ProductPricingModel> getPendingCreates();
  List<ProductPricingModel> getPendingUpdates();
  List<String> getPendingDeletions();

  Future<void> clearAll();
}

class ProductPricingLocalDataSourceImpl
    implements ProductPricingLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _updatedBox;
  final Box<String> _deletedBox;

  ProductPricingLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box updatedBox,
    required Box<String> deletedBox,
  }) : _mainBox = mainBox,
       _createdBox = createdBox,
       _updatedBox = updatedBox,
       _deletedBox = deletedBox;

  @override
  Future<void> addCreatedPricing(ProductPricingModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _createdBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addUpdatedPricing(ProductPricingModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _updatedBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addDeletedPricingId(String id) async {
    await _mainBox.delete(id);
    await _deletedBox.put(id, id);
  }

  @override
  Future<void> applyCreate(ProductPricingModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyUpdate(ProductPricingModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyDelete(String id) async {
    await _mainBox.delete(id);
  }

  @override
  List<ProductPricingModel> getAllLocalPricing() {
    try {
      final userUid = SessionManager.getUserSession();

      var res = _mainBox.values
          .toList()
          .where((x) => x['creatorId'] == userUid!.id)
          .toList()
          .map((m) => ProductPricingModel.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      return res;
    } on LocalException catch (e) {
      throw (LocalException(message: e.message, statusCode: 505));
    }
  }

  @override
  List<ProductPricingModel> getPendingCreates() {
    return _createdBox.values
        .map((m) => ProductPricingModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<ProductPricingModel> getPendingUpdates() {
    return _updatedBox.values
        .map((m) => ProductPricingModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<String> getPendingDeletions() {
    return _deletedBox.values.toList();
  }

  @override
  Future<void> clearAll() async {
    await _mainBox.clear();
    await _createdBox.clear();
    await _updatedBox.clear();
    await _deletedBox.clear();
  }
}
