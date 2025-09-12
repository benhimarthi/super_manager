import 'package:uuid/uuid.dart';

import '../../domain/entities/inventory.dart';

class InventoryModel extends Inventory {
  const InventoryModel({
    required super.id,
    required super.productId,
    required super.warehouseId,
    required super.quantityAvailable,
    required super.quantityReserved,
    required super.quantitySold,
    required super.reorderLevel,
    required super.minimumStock,
    required super.maximumStock,
    required super.isOutOfStock,
    required super.isLowStock,
    required super.isBlocked,
    required super.lastRestockDate,
    required super.createdAt,
    required super.updatedAt,
    required super.userUid,
    required super.lostSaleOpportunitiesQuantity,
    required super.adminId,
  });

  factory InventoryModel.fromEntity(Inventory entity) {
    return InventoryModel(
      id: entity.id,
      productId: entity.productId,
      userUid: entity.userUid,
      warehouseId: entity.warehouseId,
      quantityAvailable: entity.quantityAvailable,
      quantityReserved: entity.quantityReserved,
      quantitySold: entity.quantitySold,
      reorderLevel: entity.reorderLevel,
      minimumStock: entity.minimumStock,
      maximumStock: entity.maximumStock,
      isOutOfStock: entity.isOutOfStock,
      isLowStock: entity.isLowStock,
      isBlocked: entity.isBlocked,
      lastRestockDate: entity.lastRestockDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lostSaleOpportunitiesQuantity: entity.lostSaleOpportunitiesQuantity,
      adminId: entity.adminId,
    );
  }

  Inventory toEntity() {
    return Inventory(
      id: id,
      productId: productId,
      userUid: userUid,
      warehouseId: warehouseId,
      quantityAvailable: quantityAvailable,
      quantityReserved: quantityReserved,
      quantitySold: quantitySold,
      reorderLevel: reorderLevel,
      minimumStock: minimumStock,
      maximumStock: maximumStock,
      isOutOfStock: isOutOfStock,
      isLowStock: isLowStock,
      isBlocked: isBlocked,
      lastRestockDate: lastRestockDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lostSaleOpportunitiesQuantity: lostSaleOpportunitiesQuantity,
      adminId: adminId,
    );
  }

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map['id'] as String,
      productId: map['productId'] as String,
      userUid: map['userUid'] as String,
      warehouseId: map['warehouseId'] as String,
      quantityAvailable: map['quantityAvailable'] as int,
      quantityReserved: map['quantityReserved'] as int,
      quantitySold: map['quantitySold'] as int,
      reorderLevel: map['reorderLevel'] as int,
      minimumStock: map['minimumStock'] as int,
      maximumStock: map['maximumStock'] as int,
      isOutOfStock: map['isOutOfStock'] as bool,
      isLowStock: map['isLowStock'] as bool,
      isBlocked: map['isBlocked'] as bool,
      lastRestockDate: DateTime.parse(map['lastRestockDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      lostSaleOpportunitiesQuantity:
          map['lostSaleOpportunitiesQuantity'] as int,
      adminId: (map['adminId'] ?? "") as String,
    );
  }

  InventoryModel copyWith({
    String? id,
    String? productId,
    String? userUid,
    String? warehouseId,
    int? quantityAvailable,
    int? quantityReserved,
    int? quantitySold,
    int? reorderLevel,
    int? minimumStock,
    int? maximumStock,
    bool? isOutOfStock,
    bool? isLowStock,
    bool? isBlocked,
    DateTime? lastRestockDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? lostSaleOpportunitiesQuantity,
    String? adminId,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      quantityReserved: quantityReserved ?? this.quantityReserved,
      quantitySold: quantitySold ?? this.quantitySold,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      isLowStock: isLowStock ?? this.isLowStock,
      isBlocked: isBlocked ?? this.isBlocked,
      lastRestockDate: lastRestockDate ?? this.lastRestockDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userUid: userUid ?? this.userUid,
      lostSaleOpportunitiesQuantity:
          lostSaleOpportunitiesQuantity ?? this.lostSaleOpportunitiesQuantity,
      adminId: adminId ?? this.adminId,
    );
  }

  factory InventoryModel.empty() {
    return InventoryModel(
      id: Uuid().v4(),
      productId: "",
      warehouseId: "",
      userUid: "",
      quantityAvailable: 0,
      quantityReserved: 0,
      quantitySold: 0,
      reorderLevel: 0,
      minimumStock: 0,
      maximumStock: 0,
      isOutOfStock: false,
      isLowStock: false,
      isBlocked: false,
      lastRestockDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lostSaleOpportunitiesQuantity: 0,
      adminId: "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'userUid': userUid,
      'quantityAvailable': quantityAvailable,
      'quantityReserved': quantityReserved,
      'quantitySold': quantitySold,
      'reorderLevel': reorderLevel,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'isOutOfStock': isOutOfStock,
      'isLowStock': isLowStock,
      'isBlocked': isBlocked,
      'lastRestockDate': lastRestockDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lostSaleOpportunitiesQuantity': lostSaleOpportunitiesQuantity,
      'adminId': adminId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    warehouseId,
    quantityAvailable,
    quantityReserved,
    quantitySold,
    reorderLevel,
    minimumStock,
    maximumStock,
    isOutOfStock,
    isLowStock,
    isBlocked,
    lastRestockDate,
    createdAt,
    updatedAt,
  ];
}
