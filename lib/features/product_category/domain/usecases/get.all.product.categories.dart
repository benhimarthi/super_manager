import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.category.dart';
import '../repositories/product.category.repository.dart';

class GetAllProductCategories
    extends UseCaseWithoutParams<List<ProductCategory>> {
  final ProductCategoryRepository _repository;

  const GetAllProductCategories(this._repository);

  @override
  ResultFuture<List<ProductCategory>> call() {
    return _repository.getAllCategories();
  }
}
