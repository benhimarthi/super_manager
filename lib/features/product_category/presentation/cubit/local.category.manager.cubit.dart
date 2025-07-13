import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../synchronisation/cubit/product_category_sync_manager_cubit/product.category.sync.trigger.cubit.dart';
import '../../domain/entities/product.category.dart';
import '../../domain/usecases/create.product.category.dart';
import '../../domain/usecases/delete.product.category.dart';
import '../../domain/usecases/get.all.product.categories.dart';
import '../../domain/usecases/update.product.category.dart';
import 'local.category.manager.state.dart';

class LocalCategoryManagerCubit extends Cubit<LocalCategoryManagerState> {
  final GetAllProductCategories _getAll;
  final CreateProductCategory _create;
  final UpdateProductCategory _update;
  final DeleteProductCategory _delete;
  final ProductCategorySyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  LocalCategoryManagerCubit({
    required GetAllProductCategories getAll,
    required CreateProductCategory create,
    required UpdateProductCategory update,
    required DeleteProductCategory delete,
    required ProductCategorySyncTriggerCubit syncCubit,
    required Connectivity connectivity,
  }) : _getAll = getAll,
       _create = create,
       _update = update,
       _delete = delete,
       _syncCubit = syncCubit,
       _connectivity = connectivity,
       super(LocalCategoryManagerInitial());

  Future<void> loadCategories() async {
    emit(LocalCategoryManagerLoading());

    final result = await _getAll();
    result.fold(
      (failure) => emit(LocalCategoryManagerError(failure.message)),
      (categories) => emit(LocalCategoryManagerLoaded(categories)),
    );
  }

  Future<void> addCategory(ProductCategory category) async {
    final result = await _create(category);
    result.fold((failure) => emit(LocalCategoryManagerError(failure.message)), (
      _,
    ) async {
      await loadCategories();
      await _tryAutoSync();
    });
  }

  Future<void> updateCategory(ProductCategory category) async {
    final result = await _update(category);
    result.fold((failure) => emit(LocalCategoryManagerError(failure.message)), (
      _,
    ) async {
      await loadCategories();
      await _tryAutoSync();
    });
  }

  Future<List<String>> _collectDescendantIds(
    String parentId,
    List<dynamic> all,
  ) async {
    final Map<String, List<ProductCategory>> childrenMap = {};

    for (final cat in all) {
      childrenMap.putIfAbsent(cat.parentId ?? '', () => []).add(cat);
    }

    final List<String> toDelete = [];

    void collect(String id) {
      final children = childrenMap[id] ?? [];
      for (final child in children) {
        toDelete.add(child.id);
        collect(child.id);
      }
    }

    collect(parentId);
    return toDelete;
  }

  Future<void> deleteCategory(String id) async {
    final result = await _getAll();
    final allCategories = result.fold((_) => [], (list) => list);
    final childIds = await _collectDescendantIds(id, allCategories);
    final allToDelete = [id, ...childIds];

    for (final cid in allToDelete) {
      final deletionResult = await _delete(cid);
      deletionResult.fold(
        (failure) => emit(LocalCategoryManagerError(failure.message)),
        (_) {},
      );
    }

    await loadCategories();
    await _tryAutoSync();
  }

  Future<void> _tryAutoSync() async {
    final result = await _connectivity.checkConnectivity();
    final isOnline = result != ConnectivityResult.none;
    if (isOnline) {
      await _syncCubit.triggerManualSync();
    }
  }
}
