import 'package:bloc/bloc.dart';
import '../../synchronisation_manager/inventory.meta.data.sync.manager.dart';

abstract class InventoryMetadataSyncTriggerState {}

class SyncIdle extends InventoryMetadataSyncTriggerState {}

class SyncInProgress extends InventoryMetadataSyncTriggerState {}

class SyncSuccess extends InventoryMetadataSyncTriggerState {}

class SyncFailure extends InventoryMetadataSyncTriggerState {
  final String message;
  SyncFailure(this.message);
}

class InventoryMetadataSyncTriggerCubit
    extends Cubit<InventoryMetadataSyncTriggerState> {
  final InventoryMetadataSyncManager _sync;

  InventoryMetadataSyncTriggerCubit(this._sync) : super(SyncIdle());

  Future<void> startSyncing() async {
    try {
      emit(SyncInProgress());
      await _sync.startSync();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  void stopSyncing() {
    _sync.stopSync();
    emit(SyncIdle());
  }

  Future<void> refreshFromRemote() async {
    try {
      emit(SyncInProgress());
      await _sync.pullRemoteData();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }
}
