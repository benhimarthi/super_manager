import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/sale.item.dart';
import '../repositories/sale.item.repository.dart';

class GetSaleItemsBySaleId
    implements UsecaseWithParams<List<SaleItem>, String> {
  final SaleItemRepository _repo;

  GetSaleItemsBySaleId(this._repo);

  @override
  ResultFuture<List<SaleItem>> call(String saleId) {
    return _repo.getSaleItemsBySaleId(saleId);
  }
}
