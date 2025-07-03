import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/errors/custom.exception.dart';

import '../models/app.image.model.dart';

abstract class AppImageRemoteDataSource {
  Future<void> uploadImage(AppImageModel image);
  Future<void> updateRemoteImage(AppImageModel image);
  Future<void> deleteRemoteImage(String id);
  Future<List<AppImageModel>> fetchImagesForEntity(String entityId);
  Future<AppImageModel?> fetchImageById(String id);
}

class AppImageRemoteDataSourceImpl implements AppImageRemoteDataSource {
  final FirebaseFirestore firestore;
  final CollectionReference imageCollection;

  AppImageRemoteDataSourceImpl({required this.firestore})
    : imageCollection = firestore.collection('app_images');

  @override
  Future<void> uploadImage(AppImageModel image) async {
    try {
      await imageCollection.doc(image.id).set(image.toMap());
    } on ServerException catch (e) {
      throw ServerException(message: e.message, statusCode: 500);
    }
  }

  @override
  Future<void> updateRemoteImage(AppImageModel image) async {
    await imageCollection.doc(image.id).update(image.toMap());
  }

  @override
  Future<void> deleteRemoteImage(String id) async {
    await imageCollection.doc(id).delete();
  }

  @override
  Future<List<AppImageModel>> fetchImagesForEntity(String entityId) async {
    final snapshot = await imageCollection
        .where('entityId', isEqualTo: entityId)
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => AppImageModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AppImageModel?> fetchImageById(String id) async {
    final doc = await imageCollection.doc(id).get();
    if (!doc.exists) return null;
    return AppImageModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
