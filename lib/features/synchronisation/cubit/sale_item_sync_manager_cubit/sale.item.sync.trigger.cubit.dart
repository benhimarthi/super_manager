import 'package:bloc/bloc.dart';
import '../../synchronisation_manager/sale.item.sync.manager.dart';
import '../product_pricing_sync_manager_cubit/product.pricing.sync.trigger.state.dart';

class SaleItemSyncTriggerCubit extends Cubit<ProductPricingSyncTriggerState> {
  final SaleItemSyncManager _sync;

  SaleItemSyncTriggerCubit(this._sync) : super(SyncIdle());

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
