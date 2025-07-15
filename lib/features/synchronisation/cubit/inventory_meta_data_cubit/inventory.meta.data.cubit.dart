import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../../inventory_meta_data/domain/usecases/create.inventory.meta.data.dart';
import '../../../inventory_meta_data/domain/usecases/delete.inventory.meta.data.dart';
import '../../../inventory_meta_data/domain/usecases/get.all.inventory.meta.data.data.dart';
import '../../../inventory_meta_data/domain/usecases/update.inventory.meta.data.dart';
import '../inventory_meta_data_sync_trigger_cubit/inventory.meta.data.sync.trigger.cubit.dart';
import 'inventory.meta.data.state.dart';

class InventoryMetadataCubit extends Cubit<InventoryMetadataState> {
  final GetAllInventoryMetadata _getAll;
  final CreateInventoryMetadata _create;
  final UpdateInventoryMetadata _update;
  final DeleteInventoryMetadata _delete;
  final InventoryMetadataSyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  InventoryMetadataCubit({
    required GetAllInventoryMetadata getAll,
    required CreateInventoryMetadata create,
    required UpdateInventoryMetadata update,
    required DeleteInventoryMetadata delete,
    required InventoryMetadataSyncTriggerCubit syncCubit,
    required Connectivity connectivity,
  })  : _getAll = getAll,
        _create = create,
        _update = update,
        _delete = delete,
        _syncCubit = syncCubit,
        _connectivity = connectivity,
        super(InventoryMetadataManagerInitial());

  Future<void> _tryAutoSync() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _syncCubit.triggerManualSync();
    }
  }

  Future<void> loadMetadata() async {
    emit(InventoryMetadataManagerLoading());
    final result = await _getAll();
    result.fold(
      (failure) => emit(InventoryMetadataManagerError(failure.message)),
      (list) => emit(InventoryMetadataManagerLoaded(list)),
    );
  }

  Future<void> addMetadata(InventoryMetadata metadata) async {
    final result = await _create(metadata);
    result.fold(
      (failure) => emit(InventoryMetadataManagerError(failure.message)),
      (_) async {
        await loadMetadata();
        await _tryAutoSync();
      },
    );
  }

  Future<void> updateMetadata(InventoryMetadata metadata) async {
    final result = await _update(metadata);
    result.fold(
      (failure) => emit(InventoryMetadataManagerError(failure.message)),
      (_) async {
        await loadMetadata();
        await _tryAutoSync();
      },
    );
  }

  Future<void> deleteMetadata(String id) async {
    final result = await _delete(id);
    result.fold(
      (failure) => emit(InventoryMetadataManagerError(failure.message)),
      (_) async {
        await loadMetadata();
        await _tryAutoSync();
      },
    );
  }
}
