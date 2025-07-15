import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/inventory.meta.data.dart';
import '../../domain/repositories/inventory.meta.data.repository.dart';
import '../data_source/inventory.meta.data.local.data.source.dart';
import '../models/inventory.meta.data.model.dart';

class InventoryMetadataRepositoryImpl implements InventoryMetadataRepository {
  final InventoryMetadataLocalDataSource _local;

  InventoryMetadataRepositoryImpl({
    required InventoryMetadataLocalDataSource local,
  }) : _local = local;

  @override
  ResultFuture<void> createMetadata(InventoryMetadata metadata) async {
    try {
      final model = InventoryMetadataModel.fromEntity(metadata);
      await _local.addCreatedMetadata(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<InventoryMetadata>> getAllMetadata() async {
    try {
      final models = _local.getAllLocalMetadata();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<InventoryMetadata> getMetadataById(String id) async {
    try {
      final list = _local.getAllLocalMetadata();
      final found = list.firstWhere((e) => e.id == id);
      return Right(found.toEntity());
    } catch (e) {
      return const Left(
          LocalFailure(message: 'Metadata not found', statusCode: 500));
    }
  }

  @override
  ResultFuture<void> updateMetadata(InventoryMetadata metadata) async {
    try {
      final model = InventoryMetadataModel.fromEntity(metadata);
      await _local.addUpdatedMetadata(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deleteMetadata(String id) async {
    try {
      await _local.addDeletedMetadataId(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
