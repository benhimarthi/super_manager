import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_manager/core/session/session.manager.dart';

import '../../image_manager/data/data_source/app.image.local.data.source.dart';
import '../../image_manager/data/data_source/app.image.remote.data.source.dart';
import '../../image_manager/data/models/app.image.model.dart';

abstract class AppImageSyncManager {
  Future<void> pushLocalChanges();
  Future<void> pullRemoteData();
  Future<void> refreshFromRemote();
  void startListeningToRemoteChanges();
  void stopListeningToRemoteChanges();
  void initialize();
  void dispose();
}

class AppImageSyncManagerImpl implements AppImageSyncManager {
  final AppImageLocalDataSource _local;
  final AppImageRemoteDataSource _remote;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot>? _remoteSubscription;

  AppImageSyncManagerImpl(this._local, this._remote, this._firestore);

  @override
  void initialize() {
    startListeningToRemoteChanges();
  }

  @override
  void dispose() {
    stopListeningToRemoteChanges();
  }

  @override
  Future<void> pushLocalChanges() async {
    final created = await _local.getCreatedImages();
    for (final image in created) {
      try {
        await _remote.uploadImage(image);
        await _local.clearCreatedImage(image.id);
      } catch (e) {
        print('Error pushing creation for image ${image.id}: $e');
      }
    }

    final updated = await _local.getUpdatedImages();
    for (final image in updated) {
      try {
        await _remote.updateRemoteImage(image);
        await _local.clearUpdatedImage(image.id);
      } catch (e) {
        print('Error pushing update for image ${image.id}: $e');
      }
    }

    final deleted = await _local.getDeletedImageIds();
    for (final id in deleted) {
      try {
        await _remote.deleteRemoteImage(id);
        await _local.clearDeletedImage(id);
      } catch (e) {
        print('Error pushing deletion for image $id: $e');
      }
    }
  }

  @override
  Future<void> pullRemoteData() async {
    final remoteList = await _remote.fetchImagesForEntity('');
    for (final remoteImage in remoteList) {
      final localImage = await _local.getImageById(remoteImage.id);
      if (localImage == null) {
        await _local.applyCreate(remoteImage);
      } else if (remoteImage.updatedAt.isAfter(localImage.updatedAt)) {
        await _local.applyUpdate(remoteImage);
      }
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    await pullRemoteData();
  }

  @override
  void startListeningToRemoteChanges() {
    _remoteSubscription =
        _firestore.collection('images').snapshots().listen((snapshot) async {
      if (SessionManager.getUserSession() == null) return;
      final currentUserId = SessionManager.getUserSession()!.id;

      for (final change in snapshot.docChanges) {
        final imageData = change.doc.data();
        if (imageData == null) continue;

        if (imageData['creatorID'] == currentUserId) continue;

        final remoteImage = AppImageModel.fromMap(imageData);
        final localImage = await _local.getImageById(remoteImage.id);

        switch (change.type) {
          case DocumentChangeType.added:
            if (localImage == null) {
              await _local.applyCreate(remoteImage);
            }
            break;
          case DocumentChangeType.modified:
            if (localImage == null ||
                remoteImage.updatedAt.isAfter(localImage.updatedAt)) {
              await _local.applyUpdate(remoteImage);
            }
            break;
          case DocumentChangeType.removed:
            if (localImage != null) {
              await _local.applyDelete(remoteImage.id);
            }
            break;
        }
      }
    });
  }

  @override
  void stopListeningToRemoteChanges() {
    _remoteSubscription?.cancel();
    _remoteSubscription = null;
  }
}
