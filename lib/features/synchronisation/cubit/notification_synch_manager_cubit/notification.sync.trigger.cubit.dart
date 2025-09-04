import 'package:flutter_bloc/flutter_bloc.dart';

import '../../synchronisation_manager/notification.sync.manager.dart';
import '../product_pricing_sync_manager_cubit/product.pricing.sync.trigger.state.dart';

class NotificationSyncTriggerCubit
    extends Cubit<ProductPricingSyncTriggerState> {
  final NotificationSyncManager _sync;

  NotificationSyncTriggerCubit(this._sync) : super(SyncIdle());

  Future<void> triggerManualSync() async {
    try {
      emit(SyncInProgress());
      await _sync.pushLocalChanges();
      await _sync.pullRemoteData();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  Future<void> refreshFromRemote() async {
    try {
      emit(SyncInProgress());
      await _sync.refreshFromRemote();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }
}
