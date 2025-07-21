import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:super_manager/features/sale_item/presentation/cubit/sale.item.state.dart';
import '../../../synchronisation/cubit/sale_item_sync_manager_cubit/sale.item.sync.trigger.cubit.dart';
import '../../domain/entities/sale.item.dart';
import '../../domain/usecases/create.sale.item.dart';
import '../../domain/usecases/delete.sale.item.dart';
import '../../domain/usecases/get.sale.items.by.sale.id.dart';
import '../../domain/usecases/update.sale.item.dart';

class SaleItemCubit extends Cubit<SaleItemState> {
  final GetSaleItemsBySaleId _getBySaleId;
  final CreateSaleItem _create;
  final UpdateSaleItem _update;
  final DeleteSaleItem _delete;
  final SaleItemSyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  SaleItemCubit({
    required GetSaleItemsBySaleId getBySaleId,
    required CreateSaleItem create,
    required UpdateSaleItem update,
    required DeleteSaleItem delete,
    required SaleItemSyncTriggerCubit syncCubit,
    required Connectivity connectivity,
  }) : _getBySaleId = getBySaleId,
       _create = create,
       _update = update,
       _delete = delete,
       _syncCubit = syncCubit,
       _connectivity = connectivity,
       super(SaleItemManagerInitial());

  Future<void> _tryAutoSync() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _syncCubit.triggerManualSync();
    }
  }

  Future<void> loadSaleItems(String saleId) async {
    emit(SaleItemManagerLoading());
    final result = await _getBySaleId(saleId);
    result.fold(
      (failure) => emit(SaleItemManagerError(failure.message)),
      (list) => emit(SaleItemManagerLoaded(list)),
    );
  }

  Future<void> addSaleItem(SaleItem item) async {
    final result = await _create(item);
    result.fold((failure) => emit(SaleItemManagerError(failure.message)), (
      _,
    ) async {
      await loadSaleItems(item.saleId);
      await _tryAutoSync();
    });
  }

  Future<void> updateSaleItem(SaleItem item) async {
    final result = await _update(item);
    result.fold((failure) => emit(SaleItemManagerError(failure.message)), (
      _,
    ) async {
      await loadSaleItems(item.saleId);
      await _tryAutoSync();
    });
  }

  Future<void> deleteSaleItem(String id, String saleId) async {
    final result = await _delete(id);
    result.fold((failure) => emit(SaleItemManagerError(failure.message)), (
      _,
    ) async {
      await loadSaleItems(saleId);
      await _tryAutoSync();
    });
  }
}
