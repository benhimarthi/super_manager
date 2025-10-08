import 'package:bloc/bloc.dart';
import '../../synchronisation_manager/inventory.sync.manager.dart';

abstract class InventorySyncTriggerState {}

class SyncIdle extends InventorySyncTriggerState {}

class SyncInProgress extends InventorySyncTriggerState {}

class SyncSuccess extends InventorySyncTriggerState {}

class SyncFailure extends InventorySyncTriggerState {
  final String message;
  SyncFailure(this.message);
}

class InventorySyncTriggerCubit extends Cubit<InventorySyncTriggerState> {
  final InventorySyncManager _sync;

  InventorySyncTriggerCubit(this._sync) : super(SyncIdle());

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
