import 'package:hive/hive.dart';

import '../models/sale.model.dart';

abstract class SaleLocalDataSource {
  Future<void> addCreatedSale(SaleModel model);
  Future<void> addUpdatedSale(SaleModel model);
  Future<void> addDeletedSaleId(String id);

  Future<void> applyCreate(SaleModel model);
  Future<void> applyUpdate(SaleModel model);
  Future<void> applyDelete(String id);

  Future<SaleModel?> getSaleById(String id);
  Future<List<SaleModel>> getAllLocalSales();

  Future<List<SaleModel>> getPendingCreates();
  Future<List<SaleModel>> getPendingUpdates();
  Future<List<String>> getPendingDeletions();

  Future<void> removeSyncedCreation(String id);
  Future<void> removeSyncedUpdate(String id);
  Future<void> removeSyncedDeletion(String id);

  Future<void> clearAll();
}

class SaleLocalDataSourceImpl implements SaleLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _updatedBox;
  final Box<String> _deletedBox;

  SaleLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box updatedBox,
    required Box<String> deletedBox,
  })  : _mainBox = mainBox,
        _createdBox = createdBox,
        _updatedBox = updatedBox,
        _deletedBox = deletedBox;

  @override
  Future<void> addCreatedSale(SaleModel model) async {
    await _createdBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addUpdatedSale(SaleModel model) async {
    await _updatedBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addDeletedSaleId(String id) async {
    await _deletedBox.put(id, id);
  }

  @override
  Future<void> applyCreate(SaleModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyUpdate(SaleModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyDelete(String id) async {
    await _mainBox.delete(id);
  }

  @override
  Future<SaleModel?> getSaleById(String id) async {
    final map = _mainBox.get(id);
    if (map == null) return null;
    return SaleModel.fromMap(Map<String, dynamic>.from(map));
  }

  @override
  Future<List<SaleModel>> getAllLocalSales() async {
    return _mainBox.values
        .map((m) => SaleModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<List<SaleModel>> getPendingCreates() async {
    return _createdBox.values
        .map((m) => SaleModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<List<SaleModel>> getPendingUpdates() async {
    return _updatedBox.values
        .map((m) => SaleModel.fromMap(Map<String, dynamic>.from(m)))
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
