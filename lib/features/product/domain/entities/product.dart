import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String unit;
  final String barcode;
  final String imageUrl;
  final String pricingId;
  final bool active;
  final String creatorID;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String adminId;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.unit,
    required this.barcode,
    required this.imageUrl,
    required this.pricingId,
    required this.active,
    required this.creatorID,
    required this.createdAt,
    required this.updatedAt,
    required this.adminId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    categoryId,
    unit,
    barcode,
    imageUrl,
    pricingId,
    active,
    createdAt,
    updatedAt,
  ];
}
