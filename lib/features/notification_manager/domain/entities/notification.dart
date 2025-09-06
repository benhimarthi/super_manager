import 'package:equatable/equatable.dart';

class Notifications extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type; // e.g., 'message'
  final String priority; // e.g., 'high'
  final String status; // e.g., 'unread', 'read'
  final String recipientId;
  final String senderId;
  final String? groupId;
  final DateTime createdAt;
  final DateTime sentAt;
  final DateTime? readAt;
  final DateTime expiresAt;
  final String channel; // e.g., 'push'
  final bool isDelivered;
  final String deviceToken;
  final String actionUrl;
  final List<String> actions;
  final Map<String, dynamic> metadata;
  final int retriesCount;
  final String? errorMessage;
  final int readCount;
  final String adminId;

  const Notifications({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.status,
    required this.recipientId,
    required this.senderId,
    this.groupId,
    required this.createdAt,
    required this.sentAt,
    this.readAt,
    required this.expiresAt,
    required this.channel,
    required this.isDelivered,
    required this.deviceToken,
    required this.actionUrl,
    required this.actions,
    required this.metadata,
    required this.retriesCount,
    this.errorMessage,
    required this.readCount,
    required this.adminId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    priority,
    status,
    recipientId,
    senderId,
    groupId,
    createdAt,
    sentAt,
    readAt,
    expiresAt,
    channel,
    isDelivered,
    deviceToken,
    actionUrl,
    actions,
    metadata,
    retriesCount,
    errorMessage,
    readCount,
  ];
}
