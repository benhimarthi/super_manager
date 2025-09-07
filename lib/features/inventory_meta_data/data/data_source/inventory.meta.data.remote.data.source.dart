import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/errors/custom.exception.dart';
import 'package:super_manager/core/errors/failure.dart';

import '../../../../core/session/session.manager.dart';
import '../models/inventory.meta.data.model.dart';

abstract class InventoryMetadataRemoteDataSource {
  Future<void> createMetadata(InventoryMetadataModel model);
  Future<List<InventoryMetadataModel>> getAllMetadata();
  Future<InventoryMetadataModel> getMetadataById(String id);
  Future<void> updateMetadata(InventoryMetadataModel model);
  Future<void> deleteMetadata(String id);
}

class InventoryMetadataRemoteDataSourceImpl
    implements InventoryMetadataRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'inventory_metadata';

  InventoryMetadataRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createMetadata(InventoryMetadataModel model) async {
    final uid = SessionManager.getUserSession()!.id;
    final data = model.toMap()..addAll({'creatorId': uid});
    await _firestore.collection(_collection).doc(model.id).set(data);
  }

  @override
  Future<List<InventoryMetadataModel>> getAllMetadata() async {
    try {
      final uid =
          SessionManager.getUserSession()!.administratorId ??
          SessionManager.getUserSession()!.id;
      final snapshot = await _firestore
          .collection(_collection)
          .where('adminId', isEqualTo: uid)
          .get();
      return snapshot.docs
          .map((doc) => InventoryMetadataModel.fromMap(doc.data()))
          .toList();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: 500);
    }
  }

  @override
  Future<InventoryMetadataModel> getMetadataById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Metadata not found');
    return InventoryMetadataModel.fromMap(doc.data()!);
  }

  @override
  Future<void> updateMetadata(InventoryMetadataModel model) async {
    final data = model.toMap();
    await _firestore.collection(_collection).doc(model.id).update(data);
  }

  @override
  Future<void> deleteMetadata(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
