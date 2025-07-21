import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/sale.item.repository.dart';

class DeleteSaleItem implements UsecaseWithParams<void, String> {
  final SaleItemRepository _repo;

  DeleteSaleItem(this._repo);

  @override
  ResultFuture<void> call(String id) {
    return _repo.deleteSaleItem(id);
  }
}
