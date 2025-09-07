import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/session/session.manager.dart';
import '../models/sale.model.dart';

abstract class SaleRemoteDataSource {
  Future<void> createSale(SaleModel model);
  Future<List<SaleModel>> getAllSales();
  Future<SaleModel> getSaleById(String id);
  Future<void> updateSale(SaleModel model);
  Future<void> deleteSale(String id);
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'sales';

  SaleRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createSale(SaleModel model) async {
    final uid = SessionManager.getUserSession()!.id;
    final data = model.toMap()..addAll({'creatorId': uid});
    await _firestore.collection(_collection).doc(model.id).set(data);
  }

  @override
  Future<List<SaleModel>> getAllSales() async {
    final uid =
        SessionManager.getUserSession()!.administratorId ??
        SessionManager.getUserSession()!.id;
    final snapshot = await _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: uid)
        .get();

    return snapshot.docs.map((doc) => SaleModel.fromMap(doc.data())).toList();
  }

  @override
  Future<SaleModel> getSaleById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Sale not found');
    return SaleModel.fromMap(doc.data()!);
  }

  @override
  Future<void> updateSale(SaleModel model) async {
    final data = model.toMap();
    await _firestore.collection(_collection).doc(model.id).update(data);
  }

  @override
  Future<void> deleteSale(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
