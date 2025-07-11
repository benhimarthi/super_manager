import '../../domain/entities/product.pricing.dart';

class ProductPricingModel extends ProductPricing {
  const ProductPricingModel({
    required super.id,
    required super.productId,
    required super.currency,
    required super.country,
    required super.amount,
    required super.discountPercent,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required super.creatorId,
  });

  factory ProductPricingModel.fromEntity(ProductPricing entity) {
    return ProductPricingModel(
      id: entity.id,
      productId: entity.productId,
      creatorId: entity.creatorId,
      currency: entity.currency,
      country: entity.country,
      amount: entity.amount,
      discountPercent: entity.discountPercent,
      active: entity.active,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ProductPricing toEntity() {
    return ProductPricing(
      id: id,
      productId: productId,
      currency: currency,
      creatorId: creatorId,
      country: country,
      amount: amount,
      discountPercent: discountPercent,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  ProductPricing copyWith({
    String? productId,
    String? currency,
    String? country,
    double? amount,
    double? discountPercent,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creatorId,
  }) {
    return ProductPricing(
      id: id,
      productId: productId ?? this.productId,
      creatorId: creatorId ?? this.creatorId,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      amount: amount ?? this.amount,
      discountPercent: discountPercent ?? this.discountPercent,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProductPricingModel.fromMap(Map<String, dynamic> map) {
    return ProductPricingModel(
      id: map['id'] as String,
      productId: map['productId'] as String,
      currency: map['currency'] as String,
      creatorId: map['creatorId'] as String,
      country: map['country'] as String,
      amount: (map['amount'] as num).toDouble(),
      discountPercent: (map['discountPercent'] as num).toDouble(),
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'currency': currency,
      'country': country,
      'amount': amount,
      'discountPercent': discountPercent,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
      'creatorId': creatorId,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    currency,
    country,
    amount,
    discountPercent,
    active,
    createdAt,
    updatedAt,
    creatorId,
  ];
}
