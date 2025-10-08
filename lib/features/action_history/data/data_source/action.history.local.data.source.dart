import 'package:hive/hive.dart';
import 'package:super_manager/core/errors/custom.exception.dart';

import '../models/action.history.model.dart';

abstract class ActionHistoryLocalDataSource {
  Future<void> addCreatedAction(ActionHistoryModel model);
  Future<void> addDeletedAction(String entityId, DateTime timestamp);

  Future<void> applyCreate(ActionHistoryModel model);
  Future<void> applyDelete(String entityId, DateTime timestamp);

  Future<ActionHistoryModel?> getAction(String entityId, DateTime timestamp);
  List<ActionHistoryModel> getAllLocalActions();

  List<ActionHistoryModel> getPendingCreates();
  List<Map<String, dynamic>> getPendingDeletions();

  Future<void> removeSyncedCreation(String entityId, DateTime timestamp);
  Future<void> removeSyncedDeletion(String entityId, DateTime timestamp);

  Future<void> clearAll();
}

class ActionHistoryLocalDataSourceImpl implements ActionHistoryLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _deletedBox;

  ActionHistoryLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box deletedBox,
  })  : _mainBox = mainBox,
        _createdBox = createdBox,
        _deletedBox = deletedBox;

  String _composeKey(String entityId, DateTime timestamp) =>
      '$entityId-${timestamp.toIso8601String()}';

  @override
  Future<ActionHistoryModel?> getAction(String entityId, DateTime timestamp) async {
    final key = _composeKey(entityId, timestamp);
    final data = _mainBox.get(key);
    if (data == null) return null;
    return ActionHistoryModel.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> addCreatedAction(ActionHistoryModel model) async {
    try {
      final key = _composeKey(model.entityId, model.timestamp);
      await _mainBox.put(key, model.toMap());
      await _createdBox.put(key, model.toMap());
    } on LocalException catch (e) {
      throw LocalException(message: e.message, statusCode: 404);
    }
  }

  @override
  Future<void> addDeletedAction(String entityId, DateTime timestamp) async {
    final key = _composeKey(entityId, timestamp);
    await _mainBox.delete(key);
    await _deletedBox.put(key, {
      'entityId': entityId,
      'timestamp': timestamp.toIso8601String(),
    });
  }

  @override
  Future<void> applyCreate(ActionHistoryModel model) async {
    await _mainBox.put(
      _composeKey(model.entityId, model.timestamp),
      model.toMap(),
    );
  }

  @override
  Future<void> applyDelete(String entityId, DateTime timestamp) async {
    await _mainBox.delete(_composeKey(entityId, timestamp));
  }

  @override
  List<ActionHistoryModel> getAllLocalActions() {
    return _mainBox.values
        .map((m) => ActionHistoryModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<ActionHistoryModel> getPendingCreates() {
    return _createdBox.values
        .map((m) => ActionHistoryModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<Map<String, dynamic>> getPendingDeletions() {
    return _deletedBox.values.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  @override
  Future<void> removeSyncedCreation(String entityId, DateTime timestamp) async {
    final key = _composeKey(entityId, timestamp);
    await _createdBox.delete(key);
  }

  @override
  Future<void> removeSyncedDeletion(String entityId, DateTime timestamp) async {
    final key = _composeKey(entityId, timestamp);
    await _deletedBox.delete(key);
  }

  @override
  Future<void> clearAll() async {
    await _mainBox.clear();
    await _createdBox.clear();
    await _deletedBox.clear();
  }
}
