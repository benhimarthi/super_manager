import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/product.pricing.repository.dart';

class DeleteProductPricing implements UsecaseWithParams<void, String> {
  final ProductPricingRepository _repo;

  DeleteProductPricing(this._repo);

  @override
  ResultFuture<void> call(String id) {
    return _repo.deletePricing(id);
  }
}
