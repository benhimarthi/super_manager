import '../../domain/entities/app.image.dart';

class AppImageModel extends AppImage {
  const AppImageModel({
    required super.id,
    required super.url,
    required super.entityId,
    required super.entityType,
    super.label,
    super.altText,
    super.position,
    super.uploadedBy,
    super.active = true,
    required super.createdAt,
    required super.updatedAt,
    required super.adminId,
  });

  factory AppImageModel.fromMap(Map<String, dynamic> map) {
    return AppImageModel(
      id: map['id'],
      url: map['url'],
      entityId: map['entityId'],
      entityType: map['entityType'],
      label: map['label'],
      altText: map['altText'],
      position: map['position'],
      uploadedBy: map['uploadedBy'],
      active: map['active'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      adminId: map['adminId'] as String,
    );
  }

  factory AppImageModel.empty() {
    return AppImageModel(
      id: "",
      url: "",
      entityId: "",
      entityType: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      adminId: "",
    );
  }

  AppImageModel copyWith({
    String? url,
    String? entityId,
    String? entityType,
    String? label,
    String? altText,
    int? position,
    String? uploadedBy,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminId,
  }) {
    return AppImageModel(
      id: id,
      url: url ?? this.url,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      altText: altText ?? this.altText,
      position: position ?? this.position,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      active: active ?? this.active,
      adminId: adminId ?? this.adminId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'entityId': entityId,
      'entityType': entityType,
      'label': label,
      'altText': altText,
      'position': position,
      'uploadedBy': uploadedBy,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppImageModel.fromEntity(AppImage image) {
    return AppImageModel(
      id: image.id,
      url: image.url,
      entityId: image.entityId,
      entityType: image.entityType,
      label: image.label,
      altText: image.altText,
      position: image.position,
      uploadedBy: image.uploadedBy,
      active: image.active,
      createdAt: image.createdAt,
      updatedAt: image.updatedAt,
      adminId: image.adminId,
    );
  }
}
