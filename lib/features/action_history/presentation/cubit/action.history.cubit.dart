import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../synchronisation/cubit/action_history_synch_manager_cubit/action.history.sync.trigger.cubit.dart';
import '../../domain/entities/action.history.dart';
import '../../domain/usecases/create.action.history.dart';
import '../../domain/usecases/delete.action.history.dart';
import '../../domain/usecases/get.all.action.history.dart';
import 'action.history.state.dart';

class ActionHistoryCubit extends Cubit<ActionHistoryState> {
  final GetAllActionHistory _getAll;
  final CreateActionHistory _create;
  final DeleteActionHistory _delete;
  final ActionHistorySyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  ActionHistoryCubit({
    required GetAllActionHistory getAll,
    required CreateActionHistory create,
    required DeleteActionHistory delete,
    required ActionHistorySyncTriggerCubit syncCubit,
    required Connectivity connectivity,
  }) : _getAll = getAll,
       _create = create,
       _delete = delete,
       _syncCubit = syncCubit,
       _connectivity = connectivity,
       super(ActionHistoryManagerInitial());

  Future<void> _tryAutoSync() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _syncCubit.triggerManualSync();
    }
  }

  Future<void> loadHistory() async {
    emit(ActionHistoryManagerLoading());
    final result = await _getAll();
    result.fold(
      (failure) => emit(ActionHistoryManagerError(failure.message)),
      (list) => emit(ActionHistoryManagerLoaded(list)),
    );
  }

  Future<void> addHistory(ActionHistory action) async {
    final result = await _create(action);
    result.fold((failure) => emit(ActionHistoryManagerError(failure.message)), (
      _,
    ) async {
      await loadHistory();
      await _tryAutoSync();
    });
  }

  Future<void> deleteHistory(String entityId, DateTime timestamp) async {
    final result = await _delete({
      'entityId': entityId,
      'timestamp': timestamp,
    });
    result.fold((failure) => emit(ActionHistoryManagerError(failure.message)), (
      _,
    ) async {
      await loadHistory();
      await _tryAutoSync();
    });
  }
}
