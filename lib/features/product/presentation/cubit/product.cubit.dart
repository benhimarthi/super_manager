import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/product/domain/usecases/get.product.by.id.dart';
import '../../../synchronisation/cubit/product_sync_manager_cubit/product.sync.trigger.cubit.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/create.product.dart';
import '../../domain/usecases/delete.product.dart';
import '../../domain/usecases/get.all.product.dart';
import '../../domain/usecases/update.product.dart';
import 'product.state.dart';

class ProductCubit extends Cubit<ProductState> {
  final CreateProduct _create;
  final GetAllProducts _getAll;
  final GetProductById _getById;
  final UpdateProduct _update;
  final DeleteProduct _delete;

  final ProductSyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  ProductCubit({
    required CreateProduct create,
    required GetAllProducts getAll,
    required GetProductById getById,
    required UpdateProduct update,
    required DeleteProduct delete,
    required ProductSyncTriggerCubit syncCubit,
    required Connectivity connectivity,
  }) : _create = create,
       _getAll = getAll,
       _getById = getById,
       _update = update,
       _delete = delete,
       _syncCubit = syncCubit,
       _connectivity = connectivity,
       super(ProductManagerLoading());

  Future<void> loadProducts() async {
    emit(ProductManagerLoading());
    final result = await _getAll();
    result.fold(
      (failure) => emit(ProductManagerError(failure.message)),
      (products) => emit(ProductManagerLoaded(products)),
    );
  }

  Future<void> addProduct(Product product) async {
    final result = await _create(product);
    if (result.isLeft()) {
      emit(ProductManagerError(result.fold((l) => l.message, (_) => '')));
    } else {
      await loadProducts();
      await _tryAutoSync();
    }
  }

  Future<void> updateProduct(Product product) async {
    final result = await _update(product);
    if (result.isLeft()) {
      emit(ProductManagerError(result.fold((l) => l.message, (_) => '')));
    } else {
      await loadProducts();
      await _tryAutoSync();
    }
  }

  Future<void> deleteProduct(String id) async {
    final result = await _delete(id);
    if (result.isLeft()) {
      emit(ProductManagerError(result.fold((l) => l.message, (_) => '')));
    } else {
      await loadProducts();
      await _tryAutoSync();
    }
  }

  Future<void> getProductById(String uid) async {
    final result = await _getById(uid);
    result.fold(
      (l) => emit(ProductManagerError(l.message)),
      (r) => emit(GetProductByIdSuccessfully(r)),
    );
  }

  Future<void> _tryAutoSync() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _syncCubit.triggerManualSync();
    }
  }
}
