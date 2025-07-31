import 'package:equatable/equatable.dart';

class ActionHistory extends Equatable {
  final DateTime timestamp;
  final String entityType;
  final String entityId;
  final String entityName;
  final String action;
  final String performedBy;
  final String performedByName;
  final Map<String, Map<String, dynamic>> changes; // field: { old, new }
  final String description;
  final Map<String, dynamic> context; // ip, device, location, etc.
  final String module;
  final String statusBefore;
  final String statusAfter;

  const ActionHistory({
    required this.timestamp,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    required this.action,
    required this.performedBy,
    required this.performedByName,
    required this.changes,
    required this.description,
    required this.context,
    required this.module,
    required this.statusBefore,
    required this.statusAfter,
  });

  @override
  List<Object?> get props => [
    timestamp,
    entityType,
    entityId,
    entityName,
    action,
    performedBy,
    performedByName,
    changes,
    description,
    context,
    module,
    statusBefore,
    statusAfter,
  ];
}
