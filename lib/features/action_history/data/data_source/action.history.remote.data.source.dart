import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/errors/custom.exception.dart';
import 'package:super_manager/core/errors/failure.dart';
import 'package:super_manager/core/session/session.manager.dart';

import '../models/action.history.model.dart';

abstract class ActionHistoryRemoteDataSource {
  Future<void> createAction(ActionHistoryModel model);
  Future<List<ActionHistoryModel>> getAllActions();
  Future<ActionHistoryModel> getActionById(String entityId, DateTime timestamp);
  Future<void> deleteAction(String entityId, DateTime timestamp);
}

class ActionHistoryRemoteDataSourceImpl
    implements ActionHistoryRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'action_history';

  ActionHistoryRemoteDataSourceImpl(this._firestore);

  String _docKey(String entityId, DateTime timestamp) =>
      '$entityId-${timestamp.toIso8601String()}';

  @override
  Future<void> createAction(ActionHistoryModel model) async {
    await _firestore
        .collection(_collection)
        .doc(_docKey(model.entityId, model.timestamp))
        .set(model.toMap());
  }

  @override
  Future<List<ActionHistoryModel>> getAllActions() async {
    try {
      final uid =
          SessionManager.getUserSession()!.administratorId ??
          SessionManager.getUserSession()!.id;
      final snapshot = await _firestore
          .collection(_collection)
          .where('adminId', isEqualTo: uid)
          .get();
      return snapshot.docs
          .map((d) => ActionHistoryModel.fromMap(d.data()))
          .toList();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: 500);
    }
  }

  @override
  Future<ActionHistoryModel> getActionById(
    String entityId,
    DateTime timestamp,
  ) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(_docKey(entityId, timestamp))
        .get();
    if (!doc.exists) throw Exception('ActionHistory not found');
    return ActionHistoryModel.fromMap(doc.data()!);
  }

  @override
  Future<void> deleteAction(String entityId, DateTime timestamp) async {
    await _firestore
        .collection(_collection)
        .doc(_docKey(entityId, timestamp))
        .delete();
  }
}
