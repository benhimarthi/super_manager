import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:super_manager/features/product_pricing/domain/usecases/get.product.pricing.by.id.dart';
import '../../../synchronisation/cubit/product_pricing_sync_manager_cubit/product.pricing.sync.trigger.cubit.dart';
import '../../domain/entities/product.pricing.dart';
import '../../domain/usecases/create.product.pricing.dart';
import '../../domain/usecases/delete.product.pricing.dart';
import '../../domain/usecases/get.all.product.pricing.dart';
import '../../domain/usecases/update.product.pricing.dart';
import 'product.pricing.state.dart';

class ProductPricingCubit extends Cubit<ProductPricingState> {
  final GetAllProductPricing _getAll;
  final GetProductPricingById _getById;
  final CreateProductPricing _create;
  final UpdateProductPricing _update;
  final DeleteProductPricing _delete;
  final ProductPricingSyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  ProductPricingCubit({
    required GetAllProductPricing getAll,
    required GetProductPricingById getById,
    required CreateProductPricing create,
    required UpdateProductPricing update,
    required DeleteProductPricing delete,
    required ProductPricingSyncTriggerCubit syncCubit,
    required Connectivity connectivity,
  }) : _getAll = getAll,
       _getById = getById,
       _create = create,
       _update = update,
       _delete = delete,
       _syncCubit = syncCubit,
       _connectivity = connectivity,
       super(ProductPricingManagerInitial());

  Future<void> _tryAutoSync() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _syncCubit.triggerManualSync();
    }
  }

  Future<void> loadPricing() async {
    emit(ProductPricingManagerLoading());
    final result = await _getAll();
    result.fold(
      (failure) => emit(ProductPricingManagerError(failure.message)),
      (list) => emit(ProductPricingManagerLoaded(list)),
    );
  }

  Future<void> addPricing(ProductPricing pricing) async {
    final result = await _create(pricing);
    result.fold(
      (failure) => emit(ProductPricingManagerError(failure.message)),
      (_) async {
        await loadPricing();
        await _tryAutoSync();
      },
    );
  }

  Future<void> updatePricing(ProductPricing pricing) async {
    final result = await _update(pricing);
    result.fold(
      (failure) => emit(ProductPricingManagerError(failure.message)),
      (_) async {
        await loadPricing();
        await _tryAutoSync();
      },
    );
  }

  Future<void> deletePricing(String id) async {
    final result = await _delete(id);
    result.fold(
      (failure) => emit(ProductPricingManagerError(failure.message)),
      (_) async {
        await loadPricing();
        await _tryAutoSync();
      },
    );
  }
}
