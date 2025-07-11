import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/product.category.repository.dart';

class DeleteProductCategory extends UsecaseWithParams<void, String> {
  final ProductCategoryRepository _repository;

  const DeleteProductCategory(this._repository);

  @override
  ResultVoid call(String params) {
    return _repository.deleteCategory(params);
  }
}
