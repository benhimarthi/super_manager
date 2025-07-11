import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String? imageUrl;
  final int? iconCodePoint;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProductCategory({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.imageUrl,
    this.iconCodePoint,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        parentId,
        imageUrl,
        iconCodePoint,
        isActive,
        createdAt,
        updatedAt,
      ];
}
