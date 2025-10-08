import 'package:hive/hive.dart';
import '../models/notification.model.dart';

abstract class NotificationLocalDataSource {
  Future<void> addCreatedNotification(NotificationModel model);
  Future<void> addUpdatedNotification(NotificationModel model);
  Future<void> addDeletedNotificationId(String id);

  Future<void> applyCreate(NotificationModel model);
  Future<void> applyUpdate(NotificationModel model);
  Future<void> applyDelete(String id);

  Future<NotificationModel?> getNotificationById(String id);
  List<NotificationModel> getAllLocalNotifications();

  List<NotificationModel> getPendingCreates();
  List<NotificationModel> getPendingUpdates();
  List<String> getPendingDeletions();

  Future<void> removeSyncedCreation(String id);
  Future<void> removeSyncedUpdate(String id);
  Future<void> removeSyncedDeletion(String id);

  Future<void> clearAll();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Box _mainBox;
  final Box _createdBox;
  final Box _updatedBox;
  final Box<String> _deletedBox;

  NotificationLocalDataSourceImpl({
    required Box mainBox,
    required Box createdBox,
    required Box updatedBox,
    required Box<String> deletedBox,
  })  : _mainBox = mainBox,
        _createdBox = createdBox,
        _updatedBox = updatedBox,
        _deletedBox = deletedBox;

  @override
  Future<void> addCreatedNotification(NotificationModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _createdBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addUpdatedNotification(NotificationModel model) async {
    await _mainBox.put(model.id, model.toMap());
    await _updatedBox.put(model.id, model.toMap());
  }

  @override
  Future<void> addDeletedNotificationId(String id) async {
    await _mainBox.delete(id);
    await _deletedBox.put(id, id);
  }

  @override
  Future<void> applyCreate(NotificationModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyUpdate(NotificationModel model) async {
    await _mainBox.put(model.id, model.toMap());
  }

  @override
  Future<void> applyDelete(String id) async {
    await _mainBox.delete(id);
  }

  @override
  Future<NotificationModel?> getNotificationById(String id) async {
    final map = _mainBox.get(id);
    if (map != null) {
      return NotificationModel.fromMap(Map<String, dynamic>.from(map));
    }
    return null;
  }

  @override
  List<NotificationModel> getAllLocalNotifications() {
    return _mainBox.values
        .map((m) => NotificationModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<NotificationModel> getPendingCreates() {
    return _createdBox.values
        .map((m) => NotificationModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  List<NotificationModel> getPendingUpdates() {
    return _updatedBox.values
        .map((m) => NotificationModel.fromMap(Map<String, dynamic>.from(m)))
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
