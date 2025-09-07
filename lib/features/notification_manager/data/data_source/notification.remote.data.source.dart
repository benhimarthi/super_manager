import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/errors/custom.exception.dart';
import 'package:super_manager/core/errors/failure.dart';

import '../../../../core/session/session.manager.dart';
import '../models/notification.model.dart';

abstract class NotificationRemoteDataSource {
  Future<void> createNotification(NotificationModel model);
  Future<List<NotificationModel>> getAllNotifications();
  Future<NotificationModel> getNotificationById(String id);
  Future<void> updateNotification(NotificationModel model);
  Future<void> deleteNotification(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'notifications';

  NotificationRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createNotification(NotificationModel model) async {
    await _firestore.collection(_collection).doc(model.id).set(model.toMap());
  }

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final uid =
          SessionManager.getUserSession()!.administratorId ??
          SessionManager.getUserSession()!.id;
      final snapshot = await _firestore
          .collection(_collection)
          .where('adminId', isEqualTo: uid)
          .get();
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: 404);
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Notification not found');
    return NotificationModel.fromMap(doc.data()!);
  }

  @override
  Future<void> updateNotification(NotificationModel model) async {
    await _firestore
        .collection(_collection)
        .doc(model.id)
        .update(model.toMap());
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
