import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/session/session.manager.dart';
import '../models/product.pricing.model.dart';

abstract class ProductPricingRemoteDataSource {
  Future<void> createPricing(ProductPricingModel model);
  Future<List<ProductPricingModel>> getAllPricing();
  Future<ProductPricingModel> getPricingById(String id);
  Future<void> updatePricing(ProductPricingModel model);
  Future<void> deletePricing(String id);
}

class ProductPricingRemoteDataSourceImpl
    implements ProductPricingRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'product_pricing';

  ProductPricingRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createPricing(ProductPricingModel model) async {
    final uid = SessionManager.getUserSession()!.id;
    final data = model.toMap()..addAll({'creatorId': uid});
    await _firestore.collection(_collection).doc(model.id).set(data);
  }

  @override
  Future<List<ProductPricingModel>> getAllPricing() async {
    final uid =
        SessionManager.getUserSession()!.administratorId ??
        SessionManager.getUserSession()!.id;
    final snapshot = await _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => ProductPricingModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<ProductPricingModel> getPricingById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Pricing not found');
    return ProductPricingModel.fromMap(doc.data()!);
  }

  @override
  Future<void> updatePricing(ProductPricingModel model) async {
    final data = model.toMap();
    await _firestore.collection(_collection).doc(model.id).update(data);
  }

  @override
  Future<void> deletePricing(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
