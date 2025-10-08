import '../../domain/entities/action.history.dart';

class ActionHistoryModel extends ActionHistory {
  const ActionHistoryModel({
    required super.timestamp,
    required super.entityType,
    required super.entityId,
    required super.entityName,
    required super.action,
    required super.performedBy,
    required super.performedByName,
    required super.changes,
    required super.description,
    required super.context,
    required super.module,
    required super.statusBefore,
    required super.statusAfter,
    required super.adminId,
  });

  factory ActionHistoryModel.fromEntity(ActionHistory entity) {
    return ActionHistoryModel(
      timestamp: entity.timestamp,
      entityType: entity.entityType,
      entityId: entity.entityId,
      entityName: entity.entityName,
      action: entity.action,
      performedBy: entity.performedBy,
      performedByName: entity.performedByName,
      changes: entity.changes,
      description: entity.description,
      context: entity.context,
      module: entity.module,
      statusBefore: entity.statusBefore,
      statusAfter: entity.statusAfter,
      adminId: entity.adminId,
    );
  }

  ActionHistory toEntity() => this;

  factory ActionHistoryModel.fromMap(Map<String, dynamic> map) {
    return ActionHistoryModel(
      timestamp: DateTime.parse(map['timestamp']),
      entityType: map['entityType'],
      entityId: map['entityId'],
      entityName: map['entityName'],
      action: map['action'],
      performedBy: map['performedBy'],
      performedByName: map['performedByName'],
      changes: Map<String, Map<String, dynamic>>.from(
        (map['changes'] as Map).map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v)),
        ),
      ),
      description: map['description'],
      context: Map<String, dynamic>.from(map['context']),
      module: map['module'],
      statusBefore: map['statusBefore'],
      statusAfter: map['statusAfter'],
      adminId: map['adminId'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'timestamp': timestamp.toIso8601String(),
    'entityType': entityType,
    'entityId': entityId,
    'entityName': entityName,
    'action': action,
    'performedBy': performedBy,
    'performedByName': performedByName,
    'changes': changes,
    'description': description,
    'context': context,
    'module': module,
    'statusBefore': statusBefore,
    'statusAfter': statusAfter,
    'adminId': adminId,
  };

}
