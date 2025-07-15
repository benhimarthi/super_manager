import 'package:equatable/equatable.dart';

class Inventory extends Equatable {
  final String id;
  final String productId;
  final String warehouseId;
  final int quantityAvailable;
  final int quantityReserved;
  final int quantitySold;
  final int reorderLevel;
  final int minimumStock;
  final int maximumStock;
  final bool isOutOfStock;
  final bool isLowStock;
  final bool isBlocked;
  final DateTime lastRestockDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Inventory({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.quantityAvailable,
    required this.quantityReserved,
    required this.quantitySold,
    required this.reorderLevel,
    required this.minimumStock,
    required this.maximumStock,
    required this.isOutOfStock,
    required this.isLowStock,
    required this.isBlocked,
    required this.lastRestockDate,
    required this.createdAt,
    required this.updatedAt,
  });

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
