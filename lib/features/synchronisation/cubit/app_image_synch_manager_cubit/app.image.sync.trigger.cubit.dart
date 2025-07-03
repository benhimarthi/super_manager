import 'package:bloc/bloc.dart';
import '../../synchronisation_manager/app.image.sync.manager.dart';
import 'app.image.sync.trigger.state.dart';

class AppImageSyncTriggerCubit extends Cubit<AppImageSyncTriggerState> {
  final AppImageSyncManager _syncManager;

  AppImageSyncTriggerCubit(this._syncManager) : super(AppImageSyncIdle());

  Future<void> triggerManualSync() async {
    emit(AppImageSyncInProgress());
    try {
      await _syncManager.pushLocalChanges();
      emit(AppImageSyncSuccess());
      emit(AppImageSyncIdle());
    } catch (e) {
      emit(AppImageSyncFailure(e.toString()));
      emit(AppImageSyncIdle());
    }
  }

  Future<void> refreshFromRemote() async {
    emit(AppImageSyncInProgress());
    try {
      await _syncManager.refreshFromRemote();
      emit(AppImageSyncSuccess());
      emit(AppImageSyncIdle());
    } catch (e) {
      emit(AppImageSyncFailure(e.toString()));
      emit(AppImageSyncIdle());
    }
  }
}
