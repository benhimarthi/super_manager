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
      await _local.addCreatedProductPricing(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<ProductPricing>> getAllPricing() async {
    try {
      final models = await _local.getAllLocalProductPricings();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<ProductPricing> getPricingById(String id) async {
    try {
      final model = await _local.getProductPricingById(id);
      if (model == null) {
        return const Left(
          LocalFailure(message: 'Pricing not found', statusCode: 404),
        );
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> updatePricing(ProductPricing pricing) async {
    try {
      final model = ProductPricingModel.fromEntity(pricing);
      await _local.addUpdatedProductPricing(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deletePricing(String id) async {
    try {
      await _local.addDeletedProductPricingId(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
