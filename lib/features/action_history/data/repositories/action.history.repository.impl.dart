import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/action.history.dart';
import '../../domain/repositories/action.history.repository.dart';
import '../data_source/action.history.local.data.source.dart';
import '../models/action.history.model.dart';

class ActionHistoryRepositoryImpl implements ActionHistoryRepository {
  final ActionHistoryLocalDataSource _local;
  // Add remote and sync as needed

  ActionHistoryRepositoryImpl({required ActionHistoryLocalDataSource local})
    : _local = local;

  @override
  ResultFuture<void> createAction(ActionHistory action) async {
    try {
      await _local.addCreatedAction(ActionHistoryModel.fromEntity(action));
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<ActionHistory>> getAllActions() async {
    try {
      final models = _local.getAllLocalActions();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<ActionHistory> getActionById(
    String entityId,
    DateTime timestamp,
  ) async {
    try {
      final models = _local.getAllLocalActions();
      final found = models.firstWhere(
        (e) => e.entityId == entityId && e.timestamp == timestamp,
      );
      return Right(found.toEntity());
    } catch (e) {
      return Left(LocalFailure(message: 'Action not found', statusCode: 404));
    }
  }

  @override
  ResultFuture<void> deleteAction(String entityId, DateTime timestamp) async {
    try {
      await _local.addDeletedAction(entityId, timestamp);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
}
