import 'package:bloc/bloc.dart';
import '../../synchronisation_manager/sale.sync.manger.dart';
import '../product_pricing_sync_manager_cubit/product.pricing.sync.trigger.state.dart';

class SaleSyncTriggerCubit extends Cubit<ProductPricingSyncTriggerState> {
  final SaleSyncManager _sync;

  SaleSyncTriggerCubit(this._sync) : super(SyncIdle());

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
