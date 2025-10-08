import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product.repository.dart';
import '../data_sources/product.local.data.source.dart';
import '../models/product.model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource _local;

  ProductRepositoryImpl({required ProductLocalDataSource local})
    : _local = local;

  @override
  ResultFuture<void> createProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);
      await _local.addCreatedProduct(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<Product>> getAllProducts() async {
    try {
      final models = await _local.getAllLocalProducts();
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<Product> getProductById(String id) async {
    try {
      final model = await _local.getProductById(id);
      if (model == null) {
        return Left(LocalFailure(message: 'Product not found', statusCode: 404));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> updateProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);
      await _local.addUpdatedProduct(model);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deleteProduct(String id) async {
    try {
      await _local.addDeletedProductId(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
