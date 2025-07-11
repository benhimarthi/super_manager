import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/product.pricing.dart';
import '../repositories/product.pricing.repository.dart';

class GetProductPricingById
    implements UsecaseWithParams<ProductPricing, String> {
  final ProductPricingRepository _repo;

  GetProductPricingById(this._repo);

  @override
  ResultFuture<ProductPricing> call(String id) {
    return _repo.getPricingById(id);
  }
}
