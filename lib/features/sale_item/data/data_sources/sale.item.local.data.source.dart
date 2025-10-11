import 'package:hive/hive.dart';

import '../models/sale.item.model.dart';

abstract class SaleItemLocalDataSource {
  Future<void> addCreatedSaleItem(SaleItemModel model);
  Future<void> addUpdatedSaleItem(SaleItemModel model);
  Future<void> addDeletedSaleItemId(String id);

  Future<void> applyCreate(SaleItemModel model);
  Future<void> applyUpdate(SaleItemModel model);
  Future<void> applyDelete(String id);

  Future<SaleItemModel?> getSaleItemById(String id);
  Future<List<SaleItemModel>> getAllLocalSaleItems();
  Future<List<SaleItemModel>> getSaleItemsBySaleId(String saleId);

  Future<List<SaleItemModel>> getPendingCreates();
  Future<List<SaleItemModel>> getPendingUpdates();
  Future<List<String>> getPendingDeletions();

  Future<void> removeSyncedCreation(String id);
  Future<void> removeSyncedUpdate(String id);
  Future<void> removeSyncedDeletion(String id);

  Future<void> clearAll();
}

class SaleItemLocalDataSourceImpl implements SaleItemLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _updatedBox;
  final Box<String> _deletedBox;

  SaleItemLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box updatedBox,
    required Box<String> deletedBox,
  }) : _mainBox = mainBox,
       _createdBox = createdBox,
       _updatedBox = updatedBox,
       _deletedBox = deletedBox;

  @override
  Future<void> addCreatedSaleItem(SaleItemModel model) async {
    await _createdBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addUpdatedSaleItem(SaleItemModel model) async {
    await _updatedBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addDeletedSaleItemId(String id) async {
    await _deletedBox.put(id, id);
  }

  @override
  Future<void> applyCreate(SaleItemModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyUpdate(SaleItemModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyDelete(String id) async {
    await _mainBox.delete(id);
  }

  @override
  Future<SaleItemModel?> getSaleItemById(String id) async {
    final map = _mainBox.get(id);
    if (map == null) return null;
    return SaleItemModel.fromMap(Map<String, dynamic>.from(map));
  }

  @override
  Future<List<SaleItemModel>> getAllLocalSaleItems() async {
    //clearAll();
    return _mainBox.values
        .map((m) => SaleItemModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<List<SaleItemModel>> getSaleItemsBySaleId(String saleId) async {
    return _mainBox.values
        .map((m) => SaleItemModel.fromMap(Map<String, dynamic>.from(m)))
        .where((item) => item.saleId == saleId)
        .toList();
  }

  @override
  Future<List<SaleItemModel>> getPendingCreates() async {
    return _createdBox.values
        .map((m) => SaleItemModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<List<SaleItemModel>> getPendingUpdates() async {
    return _updatedBox.values
        .map((m) => SaleItemModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<List<String>> getPendingDeletions() async {
    return _deletedBox.values.toList();
  }

  @override
  Future<void> removeSyncedCreation(String id) async {
    await _createdBox.delete(id);
  }

  @override
  Future<void> removeSyncedUpdate(String id) async {
    await _updatedBox.delete(id);
  }

  @override
  Future<void> removeSyncedDeletion(String id) async {
    await _deletedBox.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await _mainBox.clear();
    await _createdBox.clear();
    await _updatedBox.clear();
    await _deletedBox.clear();
  }
}
