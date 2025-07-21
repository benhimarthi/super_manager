import '../../domain/entities/sale.dart';

class SaleModel extends Sale {
  const SaleModel({
    required super.id,
    super.customerId,
    required super.date,
    required super.status,
    required super.totalAmount,
    required super.totalTax,
    required super.discountAmount,
    required super.paymentMethod,
    required super.currency,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SaleModel.fromEntity(Sale entity) {
    return SaleModel(
      id: entity.id,
      customerId: entity.customerId,
      date: entity.date,
      status: entity.status,
      totalAmount: entity.totalAmount,
      totalTax: entity.totalTax,
      discountAmount: entity.discountAmount,
      paymentMethod: entity.paymentMethod,
      currency: entity.currency,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Sale toEntity() {
    return Sale(
      id: id,
      customerId: customerId,
      date: date,
      status: status,
      totalAmount: totalAmount,
      totalTax: totalTax,
      discountAmount: discountAmount,
      paymentMethod: paymentMethod,
      currency: currency,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'] as String,
      customerId: map['customerId'] as String?,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      totalTax: (map['totalTax'] as num).toDouble(),
      discountAmount: (map['discountAmount'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] as String,
      currency: map['currency'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'date': date.toIso8601String(),
      'status': status,
      'totalAmount': totalAmount,
      'totalTax': totalTax,
      'discountAmount': discountAmount,
      'paymentMethod': paymentMethod,
      'currency': currency,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        date,
        status,
        totalAmount,
        totalTax,
        discountAmount,
        paymentMethod,
        currency,
        notes,
        createdAt,
        updatedAt,
      ];
}
