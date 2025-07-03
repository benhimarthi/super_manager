import '../../../../core/util/typedef.dart';
import '../entities/app.image.dart';

abstract class AppImageRepository {
  ResultFuture<void> createImage(AppImage image);
  ResultFuture<void> updateImage(AppImage image);
  ResultFuture<void> deleteImage(String id);
  ResultFuture<List<AppImage>> getImagesForEntity({required String entityId});
  ResultFuture<AppImage> getImageById(String id);
}
