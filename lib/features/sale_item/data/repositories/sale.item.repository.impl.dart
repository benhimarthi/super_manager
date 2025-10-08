import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/sale.item.dart';
import '../../domain/repositories/sale.item.repository.dart';
import '../data_sources/sale.item.local.data.source.dart';
import '../models/sale.item.model.dart';

class SaleItemRepositoryImpl implements SaleItemRepository {
  final SaleItemLocalDataSource _local;

  SaleItemRepositoryImpl({required SaleItemLocalDataSource local})
      : _local = local;

  @override
  ResultFuture<void> createSaleItem(SaleItem item) async {
    try {
      final model = SaleItemModel.fromEntity(item);
      await _local.addCreatedSaleItem(model);
      await _local.applyCreate(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<SaleItem>> getSaleItemsBySaleId(String saleId) async {
    try {
      final models = await _local.getSaleItemsBySaleId(saleId);
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<SaleItem> getSaleItemById(String id) async {
    try {
      final model = await _local.getSaleItemById(id);
      if (model == null) {
        return const Left(LocalFailure(message: 'SaleItem not found', statusCode: 404));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> updateSaleItem(SaleItem item) async {
    try {
      final model = SaleItemModel.fromEntity(item);
      await _local.addUpdatedSaleItem(model);
      await _local.applyUpdate(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deleteSaleItem(String id) async {
    try {
      await _local.addDeletedSaleItemId(id);
      await _local.applyDelete(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
