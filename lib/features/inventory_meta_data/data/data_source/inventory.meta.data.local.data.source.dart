import 'package:hive/hive.dart';

import '../models/inventory.meta.data.model.dart';

abstract class InventoryMetadataLocalDataSource {
  Future<void> addCreatedMetadata(InventoryMetadataModel model);
  Future<void> addUpdatedMetadata(InventoryMetadataModel model);
  Future<void> addDeletedMetadataId(String id);

  Future<void> applyCreate(InventoryMetadataModel model);
  Future<void> applyUpdate(InventoryMetadataModel model);
  Future<void> applyDelete(String id);

  List<InventoryMetadataModel> getAllLocalMetadata();

  List<InventoryMetadataModel> getPendingCreates();
  List<InventoryMetadataModel> getPendingUpdates();
  List<String> getPendingDeletions();

  Future<void> clearAll();
}

class InventoryMetadataLocalDataSourceImpl
    implements InventoryMetadataLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _updatedBox;
  final Box<String> _deletedBox;

  InventoryMetadataLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box updatedBox,
    required Box<String> deletedBox,
  }) : _mainBox = mainBox,
       _createdBox = createdBox,
       _updatedBox = updatedBox,
       _deletedBox = deletedBox;

  @override
  Future<void> addCreatedMetadata(InventoryMetadataModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _createdBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addUpdatedMetadata(InventoryMetadataModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _updatedBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addDeletedMetadataId(String id) async {
    await _mainBox.delete(id);
    await _deletedBox.put(id, id);
  }

  @override
  Future<void> applyCreate(InventoryMetadataModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyUpdate(InventoryMetadataModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyDelete(String id) async {
    await _mainBox.delete(id);
  }

  @override
  List<InventoryMetadataModel> getAllLocalMetadata() {
    return _mainBox.values
        .map(
          (m) => InventoryMetadataModel.fromMap(Map<String, dynamic>.from(m)),
        )
        .toList();
  }

  @override
  List<InventoryMetadataModel> getPendingCreates() {
    return _createdBox.values
        .map(
          (m) => InventoryMetadataModel.fromMap(Map<String, dynamic>.from(m)),
        )
        .toList();
  }

  @override
  List<InventoryMetadataModel> getPendingUpdates() {
    return _updatedBox.values
        .map(
          (m) => InventoryMetadataModel.fromMap(Map<String, dynamic>.from(m)),
        )
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
