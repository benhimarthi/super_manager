import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/product.pricing.dart';
import '../../domain/repositories/product.pricing.repository.dart';
import '../data_source/product.pricing.local.data.source.dart';
import '../models/product.pricing.model.dart';

class ProductPricingRepositoryImpl implements ProductPricingRepository {
  final ProductPricingLocalDataSource _local;

  ProductPricingRepositoryImpl({required ProductPricingLocalDataSource local})
    : _local = local;

  @override
  ResultFuture<void> createPricing(ProductPricing pricing) async {
    try {
      final model = ProductPricingModel.fromEntity(pricing);
      await _local.addCreatedPricing(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<ProductPricing>> getAllPricing() async {
    try {
      final models = _local.getAllLocalPricing();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<ProductPricing> getPricingById(String id) async {
    try {
      final list = _local.getAllLocalPricing();
      final found = list.firstWhere((e) => e.id == id);
      return Right(found.toEntity());
    } catch (e) {
      return const Left(
        LocalFailure(message: 'Pricing not, found', statusCode: 500),
      );
    }
  }

  @override
  ResultFuture<void> updatePricing(ProductPricing pricing) async {
    try {
      final model = ProductPricingModel.fromEntity(pricing);
      await _local.addUpdatedPricing(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deletePricing(String id) async {
    try {
      await _local.addDeletedPricingId(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
