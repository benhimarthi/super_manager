import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.dart';
import '../repositories/product.repository.dart';

class GetAllProducts implements UseCaseWithoutParams<List<Product>> {
  final ProductRepository _repo;

  GetAllProducts(this._repo);

  @override
  ResultFuture<List<Product>> call() {
    return _repo.getAllProducts();
  }
}
