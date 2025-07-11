import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.category.dart';
import '../repositories/product.category.repository.dart';

class CreateProductCategory
    extends UsecaseWithParams<ProductCategory, ProductCategory> {
  final ProductCategoryRepository _repository;

  const CreateProductCategory(this._repository);

  @override
  ResultFuture<ProductCategory> call(ProductCategory params) {
    return _repository.createCategory(params);
  }
}
