import 'package:cloud_firestore/cloud_firestore.dart';

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
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((d) => ActionHistoryModel.fromMap(d.data()))
        .toList();
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
