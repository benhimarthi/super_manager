import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../synchronisation/cubit/notification_synch_manager_cubit/notification.sync.trigger.cubit.dart';
import '../../data/models/notification.model.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/create.notification.dart';
import '../../domain/usecases/delete.notification.dart';
import '../../domain/usecases/get.all.notifications.dart';
import '../../domain/usecases/update.notification.dart';
import 'notification.state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetAllNotifications _getAll;
  final CreateNotification _create;
  final UpdateNotification _update;
  final DeleteNotification _delete;
  final NotificationSyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  NotificationCubit({
    required GetAllNotifications getAll,
    required CreateNotification create,
    required UpdateNotification update,
    required DeleteNotification delete,
    required NotificationSyncTriggerCubit syncCubit,
    required Connectivity connectivity,
  })  : _getAll = getAll,
        _create = create,
        _update = update,
        _delete = delete,
        _syncCubit = syncCubit,
        _connectivity = connectivity,
        super(NotificationManagerInitial());

  Future<void> _tryAutoSync() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _syncCubit.triggerManualSync();
    }
  }

  Future<void> loadNotifications() async {
    emit(NotificationManagerLoading());
    final result = await _getAll();
    result.fold(
      (failure) => emit(NotificationManagerError(failure.message)),
      (list) => emit(NotificationManagerLoaded(list)),
    );
  }

  Future<void> addNotification(Notifications n) async {
    final model = NotificationModel.fromEntity(n).copyWith(updatedAt: DateTime.now());
    final result = await _create(model);
    result.fold((failure) => emit(NotificationManagerError(failure.message)), (
      _,
    ) async {
      await loadNotifications();
      await _tryAutoSync();
    });
  }

  Future<void> updateNotification(Notifications n) async {
    final model = NotificationModel.fromEntity(n).copyWith(updatedAt: DateTime.now());
    final result = await _update(model);
    result.fold((failure) => emit(NotificationManagerError(failure.message)), (
      _,
    ) async {
      await loadNotifications();
      await _tryAutoSync();
    });
  }

  Future<void> deleteNotification(String id) async {
    final result = await _delete(id);
    result.fold((failure) => emit(NotificationManagerError(failure.message)), (
      _,
    ) async {
      await loadNotifications();
      await _tryAutoSync();
    });
  }
}
