import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/session/session.manager.dart';
import '../models/sale.item.model.dart';

abstract class SaleItemRemoteDataSource {
  Future<void> createSaleItem(SaleItemModel model);
  Future<List<SaleItemModel>> getSaleItemsBySaleId(String saleId);
  Future<SaleItemModel> getSaleItemById(String id);
  Future<void> updateSaleItem(SaleItemModel model);
  Future<void> deleteSaleItem(String id);
}

class SaleItemRemoteDataSourceImpl implements SaleItemRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'sale_items';

  SaleItemRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createSaleItem(SaleItemModel model) async {
    final uid = SessionManager.getUserSession()!.id;
    final data = model.toMap()..addAll({'creatorId': uid});
    await _firestore.collection(_collection).doc(model.id).set(data);
  }

  @override
  Future<List<SaleItemModel>> getSaleItemsBySaleId(String saleId) async {
    final uid = SessionManager.getUserSession()!.id;
    final snapshot = await _firestore
        .collection(_collection)
        .where('creatorId', isEqualTo: uid)
        .where('saleId', isEqualTo: saleId)
        .get();

    return snapshot.docs
        .map((doc) => SaleItemModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<SaleItemModel> getSaleItemById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('SaleItem not found');
    return SaleItemModel.fromMap(doc.data()!);
  }

  @override
  Future<void> updateSaleItem(SaleItemModel model) async {
    final data = model.toMap();
    await _firestore.collection(_collection).doc(model.id).update(data);
  }

  @override
  Future<void> deleteSaleItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
