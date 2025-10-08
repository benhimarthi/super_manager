import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/sale.item.dart';

class SaleItemModel extends SaleItem {
  const SaleItemModel({
    required super.id,
    required super.saleId,
    required super.productId,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
    required super.taxAmount,
    required super.discountApplied,
    required super.adminId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SaleItemModel.fromEntity(SaleItem entity) {
    return SaleItemModel(
      id: entity.id,
      saleId: entity.saleId,
      productId: entity.productId,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
      taxAmount: entity.taxAmount,
      discountApplied: entity.discountApplied,
      adminId: entity.adminId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SaleItem toEntity() {
    return SaleItem(
      id: id,
      saleId: saleId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      taxAmount: taxAmount,
      discountApplied: discountApplied,
      adminId: adminId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  SaleItemModel copyWith({
    String? id,
    String? saleId,
    String? productId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    double? taxAmount,
    double? discountApplied,
    String? adminId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleItemModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      taxAmount: taxAmount ?? this.taxAmount,
      discountApplied: discountApplied ?? this.discountApplied,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id'] as String,
      saleId: map['saleId'] as String,
      productId: map['productId'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      taxAmount: (map['taxAmount'] as num).toDouble(),
      discountApplied: (map['discountApplied'] as num).toDouble(),
      adminId: (map['adminId'] ?? '') as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'taxAmount': taxAmount,
      'discountApplied': discountApplied,
      'adminId': adminId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
