import '../../../../core/util/typedef.dart';
import '../../domain/entities/product.category.dart';

class ProductCategoryModel extends ProductCategory {
  const ProductCategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.parentId,
    super.imageUrl,
    super.iconCodePoint,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  // ✅ Create from JSON
  factory ProductCategoryModel.fromMap(DataMap map) {
    return ProductCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      parentId: map['parentId'] as String?,
      imageUrl: map['imageUrl'] as String?,
      iconCodePoint: map['iconCodePoint'] as int?,
      isActive: map['isActive'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // ✅ Convert to JSON
  DataMap toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parentId': parentId,
      'imageUrl': imageUrl,
      'iconCodePoint': iconCodePoint,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ✅ Build from domain entity
  factory ProductCategoryModel.fromEntity(ProductCategory category) {
    return ProductCategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      parentId: category.parentId,
      imageUrl: category.imageUrl,
      iconCodePoint: category.iconCodePoint,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
  static ProductCategoryModel empty = ProductCategoryModel(
    id: '',
    name: '',
    description: '',
    parentId: null,
    imageUrl: null,
    iconCodePoint: null,
    isActive: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}
