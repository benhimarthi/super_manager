import '../../../../core/util/typedef.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  ResultFuture<void> createProduct(Product product);
  ResultFuture<List<Product>> getAllProducts();
  ResultFuture<Product> getProductById(String id);
  ResultFuture<void> updateProduct(Product product);
  ResultFuture<void> deleteProduct(String id);
}
