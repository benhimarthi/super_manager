import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/product.repository.dart';

class DeleteProduct implements UsecaseWithParams<void, String> {
  final ProductRepository _repo;

  DeleteProduct(this._repo);

  @override
  ResultFuture<void> call(String id) {
    return _repo.deleteProduct(id);
  }
}
