import 'package:dartz/dartz.dart';
import 'package:super_manager/core/util/typedef.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification.repository.dart';
import '../data_source/notification.local.data.source.dart';
import '../data_source/notification.remote.data.source.dart';
import '../models/notification.model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource _local;

  NotificationRepositoryImpl({
    required NotificationLocalDataSource local,
    required NotificationRemoteDataSource remote,
  }) : _local = local;

  @override
  ResultFuture<void> createNotification(Notifications notification) async {
    try {
      final model = NotificationModel.fromEntity(notification);
      await _local.addCreatedNotification(model);
      // Optionally trigger sync here or let Sync Manager handle it
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<Notifications>> getAllNotifications() async {
    try {
      final models = _local.getAllLocalNotifications();
      final notifications = models.map((m) => m.toEntity()).toList();
      return Right(notifications);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<Notifications> getNotificationById(String id) async {
    try {
      final models = _local.getAllLocalNotifications();
      final found = models.firstWhere((element) => element.id == id);
      return Right(found.toEntity());
    } catch (e) {
      return Left(
        LocalFailure(message: 'Notification not found', statusCode: 404),
      );
    }
  }

  @override
  ResultFuture<void> updateNotification(Notifications notification) async {
    try {
      final model = NotificationModel.fromEntity(notification);
      await _local.addUpdatedNotification(model);
      // Optionally trigger sync here or let Sync Manager handle it
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deleteNotification(String id) async {
    try {
      await _local.addDeletedNotificationId(id);
      // Optionally trigger sync here or let Sync Manager handle it
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
