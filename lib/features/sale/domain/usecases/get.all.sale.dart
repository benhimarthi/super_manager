import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/sale.dart';
import '../repositories/sale.repository.dart';

class GetAllSales implements UseCaseWithoutParams<List<Sale>> {
  final SaleRepository _repo;

  GetAllSales(this._repo);

  @override
  ResultFuture<List<Sale>> call() {
    return _repo.getAllSales();
  }
}
