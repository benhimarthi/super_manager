import 'package:hive/hive.dart';

import '../models/sale.model.dart';

abstract class SaleLocalDataSource {
  Future<void> addCreatedSale(SaleModel model);
  Future<void> addUpdatedSale(SaleModel model);
  Future<void> addDeletedSaleId(String id);

  Future<void> applyCreate(SaleModel model);
  Future<void> applyUpdate(SaleModel model);
  Future<void> applyDelete(String id);

  List<SaleModel> getAllLocalSales();

  List<SaleModel> getPendingCreates();
  List<SaleModel> getPendingUpdates();
  List<String> getPendingDeletions();

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
    await _mainBox.put(model.id, model.toMap());
    await _createdBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addUpdatedSale(SaleModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _updatedBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addDeletedSaleId(String id) async {
    await _mainBox.delete(id);
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
  List<SaleModel> getAllLocalSales() {
    return _mainBox.values
        .map((m) => SaleModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<SaleModel> getPendingCreates() {
    return _createdBox.values
        .map((m) => SaleModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<SaleModel> getPendingUpdates() {
    return _updatedBox.values
        .map((m) => SaleModel.fromMap(Map<String, dynamic>.from(m)))
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
