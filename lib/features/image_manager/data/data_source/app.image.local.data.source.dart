import 'package:hive/hive.dart';

import '../models/app.image.model.dart';

abstract class AppImageLocalDataSource {
  Future<void> cacheImage(AppImageModel image);
  Future<void> updateImage(AppImageModel image);
  Future<void> deleteImage(String id);

  Future<AppImageModel?> getImageById(String id);
  Future<List<AppImageModel>> getImagesForEntity(String entityId);

  // 🔁 Sync staging
  Future<void> stageCreatedImage(AppImageModel image);
  Future<void> stageUpdatedImage(AppImageModel image);
  Future<void> stageDeletedImage(String id);

  Future<List<AppImageModel>> getCreatedImages();
  Future<List<AppImageModel>> getUpdatedImages();
  Future<List<String>> getDeletedImageIds();

  Future<void> clearCreatedImage(String id);
  Future<void> clearUpdatedImage(String id);
  Future<void> clearDeletedImage(String id);
  Future<void> clearAll();
}

class AppImageLocalDataSourceImpl implements AppImageLocalDataSource {
  final Box mainBox;
  final Box createdBox;
  final Box updatedBox;
  final Box deletedBox;

  AppImageLocalDataSourceImpl({
    required this.mainBox,
    required this.createdBox,
    required this.updatedBox,
    required this.deletedBox,
  });

  // Main store
  @override
  Future<void> cacheImage(AppImageModel image) async {
    await mainBox.put(image.id, image.toMap());
  }

  @override
  Future<void> updateImage(AppImageModel image) async {
    await mainBox.put(image.id, image.toMap());
  }

  @override
  Future<void> deleteImage(String id) async {
    await mainBox.delete(id);
  }

  @override
  Future<AppImageModel?> getImageById(String id) async {
    final data = mainBox.get(id);
    if (data == null) return null;
    return AppImageModel.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<AppImageModel>> getImagesForEntity(String entityId) async {
    var res = mainBox.values
        .map((e) => AppImageModel.fromMap(Map<String, dynamic>.from(e)))
        .where((img) => img.entityId == entityId && img.active)
        .toList();
    return res;
  }

  // ➕ Create Staging
  @override
  Future<void> stageCreatedImage(AppImageModel image) async {
    await cacheImage(image);
    await createdBox.put(image.id, image.toMap());
  }

  @override
  Future<List<AppImageModel>> getCreatedImages() async {
    return createdBox.values
        .map((e) => AppImageModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> clearCreatedImage(String id) async {
    await createdBox.delete(id);
  }

  // 🛠️ Update Staging
  @override
  Future<void> stageUpdatedImage(AppImageModel image) async {
    await updatedBox.put(image.id, image.toMap());
  }

  @override
  Future<List<AppImageModel>> getUpdatedImages() async {
    return updatedBox.values
        .map((e) => AppImageModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> clearUpdatedImage(String id) async {
    await updatedBox.delete(id);
  }

  // ❌ Delete Staging
  @override
  Future<void> stageDeletedImage(String id) async {
    await deletedBox.put(id, {'id': id});
  }

  @override
  Future<List<String>> getDeletedImageIds() async {
    return deletedBox.values.map((e) => (e as Map)['id'] as String).toList();
  }

  @override
  Future<void> clearDeletedImage(String id) async {
    await deletedBox.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await mainBox.clear();
    await createdBox.clear();
    await updatedBox.clear();
    await deletedBox.clear();
  }
}
