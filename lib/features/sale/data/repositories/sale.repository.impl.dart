import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale.repository.dart';
import '../data_source/sale.local.data.source.dart';
import '../models/sale.model.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleLocalDataSource _local;

  SaleRepositoryImpl({required SaleLocalDataSource local}) : _local = local;

  @override
  ResultFuture<void> createSale(Sale sale) async {
    try {
      final model = SaleModel.fromEntity(sale);
      await _local.addCreatedSale(model);
      await _local.applyCreate(model); // Also apply to main box for immediate UI update
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<Sale>> getAllSales() async {
    try {
      final models = await _local.getAllLocalSales();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<Sale> getSaleById(String id) async {
    try {
      final model = await _local.getSaleById(id);
      if (model == null) {
        return const Left(LocalFailure(message: 'Sale not found', statusCode: 404));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> updateSale(Sale sale) async {
    try {
      final model = SaleModel.fromEntity(sale);
      await _local.addUpdatedSale(model);
      await _local.applyUpdate(model); // Also apply to main box for immediate UI update
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deleteSale(String id) async {
    try {
      await _local.addDeletedSaleId(id);
      await _local.applyDelete(id); // Also apply to main box for immediate UI update
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
