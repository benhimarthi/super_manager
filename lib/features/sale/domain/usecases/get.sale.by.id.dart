import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/sale.dart';
import '../repositories/sale.repository.dart';

class GetSaleById implements UsecaseWithParams<Sale, String> {
  final SaleRepository _repo;

  GetSaleById(this._repo);

  @override
  ResultFuture<Sale> call(String id) {
    return _repo.getSaleById(id);
  }
}
