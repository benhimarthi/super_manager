import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/app.image.dart';
import '../../domain/repositories/app.image.repository.dart';
import '../data_source/app.image.local.data.source.dart';
import '../models/app.image.model.dart';

class AppImageRepositoryImpl implements AppImageRepository {
  final AppImageLocalDataSource _local;

  AppImageRepositoryImpl({required AppImageLocalDataSource local})
      : _local = local;

  @override
  ResultFuture<void> createImage(AppImage image) async {
    try {
      final model = AppImageModel.fromEntity(image);
      await _local.stageCreatedImage(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> updateImage(AppImage image) async {
    try {
      final model = AppImageModel.fromEntity(image);
      await _local.stageUpdatedImage(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deleteImage(String id) async {
    try {
      await _local.stageDeletedImage(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<AppImage> getImageById(String id) async {
    try {
      final model = await _local.getImageById(id);
      if (model == null) {
        return const Left(
            LocalFailure(message: 'Image not found', statusCode: 404));
      }
      return Right(model);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<AppImage>> getImagesForEntity(
      {required String entityId}) async {
    try {
      final models = await _local.getImagesForEntity(entityId);
      return Right(models.map((e) => e).toList());
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
