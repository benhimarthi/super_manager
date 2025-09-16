import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.unit,
    required super.barcode,
    required super.imageUrl,
    required super.pricingId,
    required super.active,
    required super.creatorID,
    required super.createdAt,
    required super.updatedAt,
    required super.adminId,
  });

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      categoryId: entity.categoryId,
      unit: entity.unit,
      barcode: entity.barcode,
      imageUrl: entity.imageUrl,
      pricingId: entity.pricingId,
      active: entity.active,
      creatorID: entity.creatorID,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      adminId: entity.adminId,
    );
  }

  factory ProductModel.empty() {
    return ProductModel(
      id: "",
      name: "",
      description: "",
      categoryId: "",
      unit: "",
      barcode: "",
      imageUrl: "",
      pricingId: "",
      active: false,
      creatorID: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      adminId: "",
    );
  }

  Product toEntity() => Product(
    id: id,
    name: name,
    description: description,
    categoryId: categoryId,
    unit: unit,
    barcode: barcode,
    imageUrl: imageUrl,
    pricingId: pricingId,
    active: active,
    creatorID: creatorID,
    createdAt: createdAt,
    updatedAt: updatedAt,
    adminId: adminId,
  );

  ProductModel copyWith({
    String? name,
    String? description,
    String? categoryId,
    String? unit,
    String? barcode,
    String? imageUrl,
    String? pricingId,
    bool? active,
    String? creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminId,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      pricingId: pricingId ?? this.pricingId,
      active: active ?? this.active,
      creatorID: creatorId ?? creatorID,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminId: adminId ?? this.adminId,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    bool active = false;
    try {
      var value = map['active'] as String;
      switch (value) {
        case "true":
          active = true;
          break;
        case "false":
          active = false;
          break;
      }
    } catch (e) {
      active = map['active'] as bool;
    }
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      categoryId: map['categoryId'] as String,
      unit: map['unit'] as String,
      barcode: map['barcode'] as String,
      imageUrl: map['imageUrl'] as String,
      pricingId: map['pricingId'] as String,
      active: active, //map['active'] as bool,
      creatorID: map['creatorID'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      adminId: map['adminId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'unit': unit,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'pricingId': pricingId,
      'active': active,
      'creatorID': creatorID,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'adminId': adminId,
    };
  }
}
