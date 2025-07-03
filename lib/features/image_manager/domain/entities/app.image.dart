import 'package:equatable/equatable.dart';

class AppImage extends Equatable {
  final String id;
  final String url;
  final String entityId;
  final String entityType; // e.g., "product", "category", etc.
  final String? label;
  final String? altText;
  final int? position;
  final String? uploadedBy;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppImage({
    required this.id,
    required this.url,
    required this.entityId,
    required this.entityType,
    this.label,
    this.altText,
    this.position,
    this.uploadedBy,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        url,
        entityId,
        entityType,
        label,
        altText,
        position,
        uploadedBy,
        active,
        createdAt,
        updatedAt,
      ];
}
