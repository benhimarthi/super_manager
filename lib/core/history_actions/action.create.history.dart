import 'package:super_manager/core/session/session.manager.dart';

import '../../features/action_history/domain/entities/action.history.dart';

ActionHistory addHistoryItem(
  String entityType,
  String entityId,
  String entityName,
  String action,
  String performedBy,
  String performedByName,
  String description,
  Map<String, Map<String, dynamic>> changes,
  Map<String, dynamic> context,
  String module,
  String statusBefore,
  String statusAfter,
) {
  return ActionHistory(
    timestamp: DateTime.now(),
    entityType: entityType,
    entityId: entityId,
    entityName: entityName,
    action: action,
    performedBy: performedBy,
    performedByName: performedByName,
    changes: changes,
    description: description,
    context: context,
    module: module,
    statusBefore: statusBefore,
    statusAfter: statusAfter,
    adminId:
        SessionManager.getUserSession()!.administratorId ??
        SessionManager.getUserSession()!.id,
  );
}
