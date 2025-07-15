import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/repositories/inventory.repository.dart';
import '../data_sources/inventory.local.data.source.dart';
import '../models/inventory.model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource _local;

  InventoryRepositoryImpl({
    required InventoryLocalDataSource local,
  }) : _local = local;

  @override
  ResultFuture<void> createInventory(Inventory inventory) async {
    try {
      final model = InventoryModel.fromEntity(inventory);
      await _local.addCreatedInventory(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<Inventory>> getAllInventory() async {
    try {
      final models = _local.getAllLocalInventory();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<Inventory> getInventoryById(String id) async {
    try {
      final list = _local.getAllLocalInventory();
      final found = list.firstWhere((e) => e.id == id);
      return Right(found.toEntity());
    } catch (e) {
      return const Left(
          LocalFailure(message: 'Inventory not found', statusCode: 500));
    }
  }

  @override
  ResultFuture<void> updateInventory(Inventory inventory) async {
    try {
      final model = InventoryModel.fromEntity(inventory);
      await _local.addUpdatedInventory(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deleteInventory(String id) async {
    try {
      await _local.addDeletedInventoryId(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
