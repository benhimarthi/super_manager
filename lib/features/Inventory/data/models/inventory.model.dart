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
    );
  }

  factory InventoryModel.empty() {
    return InventoryModel(
      id: Uuid().v4(),
      productId: "productId",
      warehouseId: "warehouseId",
      userUid: "_",
      quantityAvailable: 15,
      quantityReserved: 5,
      quantitySold: 6,
      reorderLevel: 3,
      minimumStock: 3,
      maximumStock: 120,
      isOutOfStock: false,
      isLowStock: false,
      isBlocked: false,
      lastRestockDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
