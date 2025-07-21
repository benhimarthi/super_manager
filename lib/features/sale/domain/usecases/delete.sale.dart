import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/sale.repository.dart';

class DeleteSale implements UsecaseWithParams<void, String> {
  final SaleRepository _repo;

  DeleteSale(this._repo);

  @override
  ResultFuture<void> call(String id) {
    return _repo.deleteSale(id);
  }
}
