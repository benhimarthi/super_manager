import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.category.dart';
import '../repositories/product.category.repository.dart';

class GetProductCategoryById
    extends UsecaseWithParams<ProductCategory, String> {
  final ProductCategoryRepository _repository;

  const GetProductCategoryById(this._repository);

  @override
  ResultFuture<ProductCategory> call(String params) {
    return _repository.getCategoryById(params);
  }
}
