abstract class SaleSyncTriggerState {
  const SaleSyncTriggerState();
}

class SyncInitial extends SaleSyncTriggerState {
  const SyncInitial();
}

class SyncInProgress extends SaleSyncTriggerState {
  const SyncInProgress();
}

class SyncSuccess extends SaleSyncTriggerState {
  const SyncSuccess();
}

class SyncFailure extends SaleSyncTriggerState {
  final String message;

  const SyncFailure(this.message);
}
