import 'package:hive/hive.dart';

import '../models/inventory.model.dart';

abstract class InventoryLocalDataSource {
  Future<void> addCreatedInventory(InventoryModel model);
  Future<void> addUpdatedInventory(InventoryModel model);
  Future<void> addDeletedInventoryId(String id);

  Future<void> applyCreate(InventoryModel model);
  Future<void> applyUpdate(InventoryModel model);
  Future<void> applyDelete(String id);

  Future<InventoryModel?> getInventoryById(String id);

  List<InventoryModel> getAllLocalInventory();

  List<InventoryModel> getPendingCreates();
  List<InventoryModel> getPendingUpdates();
  List<String> getPendingDeletions();

  Future<void> removeSyncedCreation(String id);
  Future<void> removeSyncedUpdate(String id);
  Future<void> removeSyncedDeletion(String id);

  Future<void> clearAll();
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _updatedBox;
  final Box<String> _deletedBox;

  InventoryLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box updatedBox,
    required Box<String> deletedBox,
  }) : _mainBox = mainBox,
       _createdBox = createdBox,
       _updatedBox = updatedBox,
       _deletedBox = deletedBox;

  @override
  Future<void> addCreatedInventory(InventoryModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _createdBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addUpdatedInventory(InventoryModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _updatedBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addDeletedInventoryId(String id) async {
    await _mainBox.delete(id);
    await _deletedBox.put(id, id);
  }

  @override
  Future<void> applyCreate(InventoryModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyUpdate(InventoryModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyDelete(String id) async {
    await _mainBox.delete(id);
  }

  @override
  Future<InventoryModel?> getInventoryById(String id) async {
    final map = _mainBox.get(id);
    if (map != null) {
      return InventoryModel.fromMap(Map<String, dynamic>.from(map));
    }
    return null;
  }

  @override
  List<InventoryModel> getAllLocalInventory() {
    //clearAll();
    return _mainBox.values
        .map((m) => InventoryModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<InventoryModel> getPendingCreates() {
    return _createdBox.values
        .map((m) => InventoryModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<InventoryModel> getPendingUpdates() {
    return _updatedBox.values
        .map((m) => InventoryModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<String> getPendingDeletions() {
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
