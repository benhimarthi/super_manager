import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/session/session.manager.dart';
import '../models/sale.model.dart';

abstract class SaleRemoteDataSource {
  Future<SaleModel> createSale(SaleModel model);
  Future<List<SaleModel>> getAllSales();
  Stream<List<SaleModel>> watchAllSales();
  Future<SaleModel> getSaleById(String id);
  Future<SaleModel> updateSale(SaleModel model);
  Future<void> deleteSale(String id);
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'sales';

  SaleRemoteDataSourceImpl(this._firestore);

  @override
  Future<SaleModel> createSale(SaleModel model) async {
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
    return SaleModel.fromMap(snapshot.data()!);
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
  Stream<List<SaleModel>> watchAllSales() {
    final uid =
        SessionManager.getUserSession()!.administratorId ??
        SessionManager.getUserSession()!.id;
    return _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SaleModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Future<SaleModel> getSaleById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Sale not found');
    return SaleModel.fromMap(doc.data()!);
  }

  @override
  Future<SaleModel> updateSale(SaleModel model) async {
    final data = model.toMap()
      ..addAll({'updatedAt': DateTime.now().toIso8601String()});
    final docRef = _firestore.collection(_collection).doc(model.id);
    await docRef.update(data);
    final snapshot = await docRef.get();
    return SaleModel.fromMap(snapshot.data()!);
  }

  @override
  Future<void> deleteSale(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
