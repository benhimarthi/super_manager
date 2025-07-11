import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.dart';
import '../repositories/product.repository.dart';

class GetProductById implements UsecaseWithParams<Product, String> {
  final ProductRepository _repo;

  GetProductById(this._repo);

  @override
  ResultFuture<Product> call(String id) {
    return _repo.getProductById(id);
  }
}
