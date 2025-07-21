import 'package:hive/hive.dart';

import '../models/sale.item.model.dart';

abstract class SaleItemLocalDataSource {
  Future<void> addCreatedSaleItem(SaleItemModel model);
  Future<void> addUpdatedSaleItem(SaleItemModel model);
  Future<void> addDeletedSaleItemId(String id);

  Future<void> applyCreate(SaleItemModel model);
  Future<void> applyUpdate(SaleItemModel model);
  Future<void> applyDelete(String id);

  List<SaleItemModel> getAllLocalSaleItems();

  List<SaleItemModel> getSaleItemsBySaleId(String saleId);

  List<SaleItemModel> getPendingCreates();
  List<SaleItemModel> getPendingUpdates();
  List<String> getPendingDeletions();

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
  })  : _mainBox = mainBox,
        _createdBox = createdBox,
        _updatedBox = updatedBox,
        _deletedBox = deletedBox;

  @override
  Future<void> addCreatedSaleItem(SaleItemModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _createdBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addUpdatedSaleItem(SaleItemModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _updatedBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addDeletedSaleItemId(String id) async {
    await _mainBox.delete(id);
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
  List<SaleItemModel> getAllLocalSaleItems() {
    return _mainBox.values
        .map((m) => SaleItemModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<SaleItemModel> getSaleItemsBySaleId(String saleId) {
    return _mainBox.values
        .map((m) => SaleItemModel.fromMap(Map<String, dynamic>.from(m)))
        .where((item) => item.saleId == saleId)
        .toList();
  }

  @override
  List<SaleItemModel> getPendingCreates() {
    return _createdBox.values
        .map((m) => SaleItemModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<SaleItemModel> getPendingUpdates() {
    return _updatedBox.values
        .map((m) => SaleItemModel.fromMap(Map<String, dynamic>.from(m)))
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
