import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:super_manager/features/sale/presentation/cubit/sale.state.dart';
import '../../../synchronisation/cubit/sale_synch_manager_cubit/sale.sync.trigger.cubit.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/create.sale.dart';
import '../../domain/usecases/delete.sale.dart';
import '../../domain/usecases/get.all.sale.dart';
import '../../domain/usecases/update.sale.dart';

class SaleCubit extends Cubit<SaleState> {
  final GetAllSales _getAll;
  final CreateSale _create;
  final UpdateSale _update;
  final DeleteSale _delete;
  final SaleSyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  SaleCubit({
    required GetAllSales getAll,
    required CreateSale create,
    required UpdateSale update,
    required DeleteSale delete,
    required SaleSyncTriggerCubit syncCubit,
    required Connectivity connectivity,
  }) : _getAll = getAll,
       _create = create,
       _update = update,
       _delete = delete,
       _syncCubit = syncCubit,
       _connectivity = connectivity,
       super(SaleManagerInitial());

  Future<void> _tryAutoSync() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _syncCubit.triggerManualSync();
    }
  }

  Future<void> loadSales() async {
    emit(SaleManagerLoading());
    final result = await _getAll();
    result.fold(
      (failure) => emit(SaleManagerError(failure.message)),
      (list) => emit(SaleManagerLoaded(list)),
    );
  }

  Future<void> addSale(Sale sale) async {
    final result = await _create(sale);
    result.fold((failure) => emit(SaleManagerError(failure.message)), (
      _,
    ) async {
      await loadSales();
      await _tryAutoSync();
    });
  }

  Future<void> updateSale(Sale sale) async {
    final result = await _update(sale);
    result.fold((failure) => emit(SaleManagerError(failure.message)), (
      _,
    ) async {
      await loadSales();
      await _tryAutoSync();
    });
  }

  Future<void> deleteSale(String id) async {
    final result = await _delete(id);
    result.fold((failure) => emit(SaleManagerError(failure.message)), (
      _,
    ) async {
      await loadSales();
      await _tryAutoSync();
    });
  }
}
