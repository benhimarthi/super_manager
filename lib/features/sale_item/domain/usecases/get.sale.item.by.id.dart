import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/sale.item.dart';
import '../repositories/sale.item.repository.dart';

class GetSaleItemById implements UsecaseWithParams<SaleItem, String> {
  final SaleItemRepository _repo;

  GetSaleItemById(this._repo);

  @override
  ResultFuture<SaleItem> call(String id) {
    return _repo.getSaleItemById(id);
  }
}
