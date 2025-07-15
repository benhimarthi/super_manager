import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/session/session.manager.dart';
import '../models/inventory.model.dart';

abstract class InventoryRemoteDataSource {
  Future<void> createInventory(InventoryModel model);
  Future<List<InventoryModel>> getAllInventory();
  Future<InventoryModel> getInventoryById(String id);
  Future<void> updateInventory(InventoryModel model);
  Future<void> deleteInventory(String id);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'inventory';

  InventoryRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createInventory(InventoryModel model) async {
    final uid = SessionManager.getUserSession()!.id;
    final data = model.toMap()..addAll({'creatorId': uid});
    await _firestore.collection(_collection).doc(model.id).set(data);
  }

  @override
  Future<List<InventoryModel>> getAllInventory() async {
    final uid = SessionManager.getUserSession()!.id;
    final snapshot = await _firestore
        .collection(_collection)
        .where('creatorId', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => InventoryModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<InventoryModel> getInventoryById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Inventory not found');
    return InventoryModel.fromMap(doc.data()!);
  }

  @override
  Future<void> updateInventory(InventoryModel model) async {
    final data = model.toMap();
    await _firestore.collection(_collection).doc(model.id).update(data);
  }

  @override
  Future<void> deleteInventory(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
