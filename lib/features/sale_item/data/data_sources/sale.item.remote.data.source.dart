import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/session/session.manager.dart';
import '../models/sale.item.model.dart';

abstract class SaleItemRemoteDataSource {
  Future<SaleItemModel> createSaleItem(SaleItemModel model);
  Future<List<SaleItemModel>> getAllSaleItems();
  Stream<List<SaleItemModel>> watchAllSaleItems();
  Future<List<SaleItemModel>> getSaleItemsBySaleId(String saleId);
  Future<SaleItemModel> getSaleItemById(String id);
  Future<SaleItemModel> updateSaleItem(SaleItemModel model);
  Future<void> deleteSaleItem(String id);
}

class SaleItemRemoteDataSourceImpl implements SaleItemRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'sale_items';

  SaleItemRemoteDataSourceImpl(this._firestore);

  @override
  Future<SaleItemModel> createSaleItem(SaleItemModel model) async {
    final uid =
        SessionManager.getUserSession()!.administratorId ??
        SessionManager.getUserSession()!.id;
    final data = model.toMap()
      ..addAll({
        'adminId': uid,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    final docRef = _firestore.collection(_collection).doc(model.id);
    await docRef.set(data);
    final snapshot = await docRef.get();
    return SaleItemModel.fromMap(snapshot.data()!);
  }

  @override
  Future<List<SaleItemModel>> getAllSaleItems() async {
    final uid =
        SessionManager.getUserSession()!.administratorId ??
        SessionManager.getUserSession()!.id;
    final snapshot = await _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: uid)
        .get();
    return snapshot.docs
        .map((doc) => SaleItemModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Stream<List<SaleItemModel>> watchAllSaleItems() {
    final uid =
        SessionManager.getUserSession()!.administratorId ??
        SessionManager.getUserSession()!.id;
    return _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SaleItemModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Future<List<SaleItemModel>> getSaleItemsBySaleId(String saleId) async {
    final uid =
        SessionManager.getUserSession()!.administratorId ??
        SessionManager.getUserSession()!.id;
    final snapshot = await _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: uid)
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
  Future<SaleItemModel> updateSaleItem(SaleItemModel model) async {
    final data = model.toMap()
      ..addAll({'updatedAt': DateTime.now().toIso8601String()});
    final docRef = _firestore.collection(_collection).doc(model.id);
    await docRef.update(data);
    final snapshot = await docRef.get();
    return SaleItemModel.fromMap(snapshot.data()!);
  }

  @override
  Future<void> deleteSaleItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
