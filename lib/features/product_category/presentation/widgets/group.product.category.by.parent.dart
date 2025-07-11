import '../../domain/entities/product.category.dart';

Map<String?, List<ProductCategory>> groupByParent(List<ProductCategory> all) {
  final Map<String?, List<ProductCategory>> grouped = {};
  for (final cat in all) {
    grouped.putIfAbsent(cat.parentId, () => []).add(cat);
  }
  return grouped;
}
