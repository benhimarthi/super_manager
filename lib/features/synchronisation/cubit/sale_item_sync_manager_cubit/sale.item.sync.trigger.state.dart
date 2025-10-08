abstract class SaleItemSyncTriggerState {
  const SaleItemSyncTriggerState();
}

class SyncInitial extends SaleItemSyncTriggerState {
  const SyncInitial();
}

class SyncInProgress extends SaleItemSyncTriggerState {
  const SyncInProgress();
}

class SyncSuccess extends SaleItemSyncTriggerState {
  const SyncSuccess();
}

class SyncFailure extends SaleItemSyncTriggerState {
  final String message;

  const SyncFailure(this.message);
}
