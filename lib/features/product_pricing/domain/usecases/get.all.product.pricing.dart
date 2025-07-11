import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.pricing.dart';
import '../repositories/product.pricing.repository.dart';

class GetAllProductPricing
    implements UseCaseWithoutParams<List<ProductPricing>> {
  final ProductPricingRepository _repo;

  GetAllProductPricing(this._repo);

  @override
  ResultFuture<List<ProductPricing>> call() {
    return _repo.getAllPricing();
  }
}
