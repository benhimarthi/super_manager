import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/sale.item.dart';
import '../repositories/sale.item.repository.dart';

class CreateSaleItem implements UsecaseWithParams<void, SaleItem> {
  final SaleItemRepository _repo;

  CreateSaleItem(this._repo);

  @override
  ResultFuture<void> call(SaleItem params) {
    return _repo.createSaleItem(params);
  }
}
