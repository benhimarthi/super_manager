import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../synchronisation/cubit/inventory_sync_trigger_cubit/inventory.sync.trigger.cubit.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/usecases/create.inventory.dart';
import '../../domain/usecases/delete.inventory.dart';
import '../../domain/usecases/get.all.inventory.dart';
import '../../domain/usecases/update.inventory.dart';
import 'inventory.state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final GetAllInventory _getAll;
  final CreateInventory _create;
  final UpdateInventory _update;
  final DeleteInventory _delete;
  final InventorySyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  InventoryCubit({
    required GetAllInventory getAll,
    required CreateInventory create,
    required UpdateInventory update,
    required DeleteInventory delete,
    required InventorySyncTriggerCubit syncCubit,
    required Connectivity connectivity,
  })  : _getAll = getAll,
        _create = create,
        _update = update,
        _delete = delete,
        _syncCubit = syncCubit,
        _connectivity = connectivity,
        super(InventoryManagerInitial());

  Future<void> _tryAutoSync() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _syncCubit.triggerManualSync();
    }
  }

  Future<void> loadInventory() async {
    emit(InventoryManagerLoading());
    final result = await _getAll();
    result.fold(
      (failure) => emit(InventoryManagerError(failure.message)),
      (list) => emit(InventoryManagerLoaded(list)),
    );
  }

  Future<void> addInventory(Inventory inventory) async {
    final result = await _create(inventory);
    result.fold(
      (failure) => emit(InventoryManagerError(failure.message)),
      (_) async {
        await loadInventory();
        await _tryAutoSync();
      },
    );
  }

  Future<void> updateInventory(Inventory inventory) async {
    final result = await _update(inventory);
    result.fold(
      (failure) => emit(InventoryManagerError(failure.message)),
      (_) async {
        await loadInventory();
        await _tryAutoSync();
      },
    );
  }

  Future<void> deleteInventory(String id) async {
    final result = await _delete(id);
    result.fold(
      (failure) => emit(InventoryManagerError(failure.message)),
      (_) async {
        await loadInventory();
        await _tryAutoSync();
      },
    );
  }
}
