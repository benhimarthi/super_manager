import '../../image_manager/data/data_source/app.image.local.data.source.dart';
import '../../image_manager/data/data_source/app.image.remote.data.source.dart';

abstract class AppImageSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote(); // optional full overwrite
}

class AppImageSyncManagerImpl implements AppImageSyncManager {
  final AppImageLocalDataSource _local;
  final AppImageRemoteDataSource _remote;

  AppImageSyncManagerImpl(this._local, this._remote);

  @override
  Future<void> pushLocalChanges() async {
    final created = await _local.getCreatedImages();
    final updated = await _local.getUpdatedImages();
    final deleted = await _local.getDeletedImageIds();
    for (final image in created) {
      await _remote.uploadImage(image);
    }
    for (final image in updated) {
      await _remote.updateRemoteImage(image);
    }
    for (final id in deleted) {
      await _remote.deleteRemoteImage(id);
    }

    for (final image in created) {
      await _local.clearCreatedImage(image.id);
    }
    for (final image in updated) {
      await _local.clearUpdatedImage(image.id);
    }
    for (final id in deleted) {
      await _local.clearDeletedImage(id);
    }
  }

  @override
  Future<void> pullRemoteData() async {
    // Optional: you could support pulling by entityType or batch criteria if desired
    // For now, we’ll assume pulling all (adjust if you scope it)
    // This example uses dummy entityId 'sync' — you'll likely iterate per-entity context
    final remoteImages = await _remote.fetchImagesForEntity('sync');

    await _local.clearAll();
    for (final image in remoteImages) {
      await _local.cacheImage(image);
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }
}
