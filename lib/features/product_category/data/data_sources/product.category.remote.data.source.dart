import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/custom.exception.dart';
import '../../../../core/session/session.manager.dart';
import '../models/product.category.model.dart';

abstract class ProductCategoryRemoteDataSource {
  Future<ProductCategoryModel> createCategory(ProductCategoryModel category);
  Future<List<ProductCategoryModel>> getAllCategories();
  Future<ProductCategoryModel> getCategoryById(String id);
  Future<ProductCategoryModel> updateCategory(ProductCategoryModel category);
  Future<void> deleteCategory(String id);
}

class ProductCategoryRemoteDataSourceImpl
    implements ProductCategoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductCategoryRemoteDataSourceImpl(this._firestore);

  CollectionReference get _collection =>
      _firestore.collection('product_categories');

  @override
  Future<ProductCategoryModel> createCategory(
      ProductCategoryModel category) async {
    try {
      String userUid = SessionManager.getUserSession()!.id;
      await _collection
          .doc(category.id)
          .set(category.toMap()..addAll({'creatorId': userUid}));
      return category;
    } catch (e) {
      throw const ServerException(
          message: 'Failed to create category', statusCode: 500);
    }
  }

  @override
  Future<List<ProductCategoryModel>> getAllCategories() async {
    try {
      String userUid = SessionManager.getUserSession()!.id;
      final snapshot =
          await _collection.where('creatorId', isEqualTo: userUid).get();
      return snapshot.docs
          .map((doc) =>
              ProductCategoryModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const ServerException(
          message: 'Failed to fetch categories', statusCode: 500);
    }
  }

  @override
  Future<ProductCategoryModel> getCategoryById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) {
        throw const ServerException(
            message: 'Category not found', statusCode: 404);
      }
      return ProductCategoryModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (_) {
      throw const ServerException(
          message: 'Failed to fetch category', statusCode: 500);
    }
  }

  @override
  Future<ProductCategoryModel> updateCategory(
      ProductCategoryModel category) async {
    try {
      await _collection.doc(category.id).update(category.toMap());
      return category;
    } catch (_) {
      throw const ServerException(
          message: 'Failed to update category', statusCode: 500);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (_) {
      throw const ServerException(
          message: 'Failed to delete category', statusCode: 500);
    }
  }
}
