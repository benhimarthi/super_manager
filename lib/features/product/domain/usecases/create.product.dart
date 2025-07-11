import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.dart';
import '../repositories/product.repository.dart';

class CreateProduct implements UsecaseWithParams<void, Product> {
  final ProductRepository _repo;

  CreateProduct(this._repo);

  @override
  ResultFuture<void> call(Product params) {
    return _repo.createProduct(params);
  }
}
