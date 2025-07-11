import 'package:dartz/dartz.dart';
import '../../../../core/errors/custom.exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/product.category.dart';
import '../../domain/repositories/product.category.repository.dart';
import '../data_sources/product.category.local.data.source.dart';
import '../models/product.category.model.dart';

class ProductCategoryRepositoryImpl implements ProductCategoryRepository {
  final ProductCategoryLocalDataSource _local;

  const ProductCategoryRepositoryImpl(this._local);

  @override
  ResultFuture<ProductCategory> createCategory(ProductCategory category) async {
    try {
      final model = ProductCategoryModel.fromEntity(category);
      await _local.addCreatedCategory(model); // 📥 mark for sync
      await _local.applyCreate(model); // 💾 save locally
      return Right(model);
    } on LocalException catch (e) {
      return Left(LocalFailure.fromLocalException(e));
    }
  }

  @override
  ResultFuture<List<ProductCategory>> getAllCategories() async {
    try {
      final models = await _local.getAllLocalCategories();
      return Right(models);
    } on LocalException catch (e) {
      return Left(LocalFailure.fromLocalException(e));
    }
  }

  @override
  ResultFuture<ProductCategory> getCategoryById(String id) async {
    try {
      final model = await _local.getLocalCategoryById(id);
      return Right(model);
    } on LocalException catch (e) {
      return Left(LocalFailure.fromLocalException(e));
    }
  }

  @override
  ResultFuture<ProductCategory> updateCategory(ProductCategory category) async {
    try {
      final model = ProductCategoryModel.fromEntity(category);
      await _local.addUpdatedCategory(model); // 🔁 mark for sync
      await _local.applyUpdate(model); // 💾 modify locally
      return Right(model);
    } on LocalException catch (e) {
      return Left(LocalFailure.fromLocalException(e));
    }
  }

  @override
  ResultVoid deleteCategory(String id) async {
    try {
      await _local.addDeletedCategoryId(id); // 🗑️ mark for remote delete
      await _local.applyDelete(id); // 💾 delete locally
      return const Right(null);
    } on LocalException catch (e) {
      return Left(LocalFailure.fromLocalException(e));
    }
  }
}
