import '../../../../core/util/typedef.dart';
import '../entities/action.history.dart';

abstract class ActionHistoryRepository {
  ResultFuture<void> createAction(ActionHistory action);
  ResultFuture<List<ActionHistory>> getAllActions();
  ResultFuture<ActionHistory> getActionById(
    String entityId,
    DateTime timestamp,
  );
  ResultFuture<void> deleteAction(String entityId, DateTime timestamp);
}
