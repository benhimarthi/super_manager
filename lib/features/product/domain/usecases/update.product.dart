import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.dart';
import '../repositories/product.repository.dart';

class UpdateProduct implements UsecaseWithParams<void, Product> {
  final ProductRepository _repo;

  UpdateProduct(this._repo);

  @override
  ResultFuture<void> call(Product params) {
    return _repo.updateProduct(params);
  }
}
