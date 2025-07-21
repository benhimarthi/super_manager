import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/sale.dart';
import '../repositories/sale.repository.dart';

class UpdateSale implements UsecaseWithParams<void, Sale> {
  final SaleRepository _repo;

  UpdateSale(this._repo);

  @override
  ResultFuture<void> call(Sale params) {
    return _repo.updateSale(params);
  }
}
