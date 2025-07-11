import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/session/session.manager.dart';
import '../models/product.model.dart';

abstract class ProductRemoteDataSource {
  Future<void> createProduct(ProductModel model);
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProductById(String id);
  Future<void> updateProduct(ProductModel model);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'products';

  ProductRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createProduct(ProductModel model) async {
    final uid = SessionManager.getUserSession()!.id;
    final data = model.toMap()..addAll({'creatorId': uid});
    await _firestore.collection(_collection).doc(model.id).set(data);
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final uid = SessionManager.getUserSession()!.id;
    final snapshot = await _firestore
        .collection(_collection)
        .where('creatorId', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Product not found');
    return ProductModel.fromMap(doc.data()!);
  }

  @override
  Future<void> updateProduct(ProductModel model) async {
    final data = model.toMap();
    await _firestore.collection(_collection).doc(model.id).update(data);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
