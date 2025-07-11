import '../../../../core/util/typedef.dart';
import '../entities/product.category.dart';

abstract class ProductCategoryRepository {
  ResultFuture<ProductCategory> createCategory(ProductCategory category);
  ResultFuture<List<ProductCategory>> getAllCategories();
  ResultFuture<ProductCategory> getCategoryById(String id);
  ResultFuture<ProductCategory> updateCategory(ProductCategory category);
  ResultVoid deleteCategory(String id);
}
