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
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<Sale>> getAllSales() async {
    try {
      final models = _local.getAllLocalSales();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<Sale> getSaleById(String id) async {
    try {
      final list = _local.getAllLocalSales();
      final found = list.firstWhere((e) => e.id == id);
      return Right(found.toEntity());
    } catch (e) {
      return const Left(
          LocalFailure(message: 'Sale not found', statusCode: 500));
    }
  }

  @override
  ResultFuture<void> updateSale(Sale sale) async {
    try {
      final model = SaleModel.fromEntity(sale);
      await _local.addUpdatedSale(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deleteSale(String id) async {
    try {
      await _local.addDeletedSaleId(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
