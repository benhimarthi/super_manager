import 'package:equatable/equatable.dart';

class ProductPricing extends Equatable {
  final String id;
  final String productId;
  final String creatorId;
  final String currency;
  final String country;
  final double amount;
  final double discountPercent;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductPricing({
    required this.id,
    required this.productId,
    required this.creatorId,
    required this.currency,
    required this.country,
    required this.amount,
    required this.discountPercent,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

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
  ];
}
