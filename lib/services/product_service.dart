import 'package:manage_hive/models/product.dart';
import 'package:manage_hive/repositories/token_repository.dart';
// Contains the Product model
import '../repositories/product_repository.dart';

// NOTE: Ensure ProductRepository and TokenRepository are imported correctly.

class ProductService {
  final ProductRepository productRepository;
  final TokenRepository tokenRepository;
  // Initialize in-memory cache for products
  List<Product> _cachedProducts = List.empty(growable: true);

  ProductService({
    required this.productRepository,
    required this.tokenRepository,
  });

  /// Creates a new product and returns the created Product object if successful.
  /// Updates the in-memory cache with the newly created product.
  Future<Product?> createProduct(Product product) async {
    String token = (await tokenRepository.getToken())!;
    // The backend returns the created Product object directly.
    final createdProduct =
        await productRepository.createProduct(product, token);

    if (createdProduct != null) {
      _cachedProducts.add(createdProduct);
    }
    return createdProduct;
  }

  /// Retrieves all products for the current user and caches them in RAM.
  Future<List<Product>> getAllProducts() async {
    String token = (await tokenRepository.getToken())!;
    final products = await productRepository.getAllProducts(token);
    _cachedProducts = products; // Overwrite cache with fresh data
    return products;
  }

  /// Returns the list of cached products.
  List<Product> get cachedProducts => _cachedProducts;

  /// Retrieves a specific product by ID.
  /// First checks the in-memory cache before making a network request.
  Future<Product?> getProduct(int id) async {
    // Try finding in cache first
    try {
      return _cachedProducts.firstWhere((prod) => prod.id == id);
    } catch (_) {
      // If not in cache, fetch from API.
      String token = (await tokenRepository.getToken())!;
      final fetchedProduct =
          await productRepository.getProduct(id, token);

      // If fetched from API, update cache for next time
      if (fetchedProduct != null) {
        _cachedProducts.add(fetchedProduct);
      }
      return fetchedProduct;
    }
  }

  /// Updates an existing product and updates the in-memory cache.
  Future<Product?> updateProduct(int id, Product product) async {
    String token = (await tokenRepository.getToken())!;
    final updatedProduct =
        await productRepository.updateProduct(id, product, token);

    if (updatedProduct != null) {
      // Find and replace the old product in the cache
      final index = _cachedProducts.indexWhere((prod) => prod.id == id);
      if (index != -1) {
        _cachedProducts[index] = updatedProduct;
      }
    }
    return updatedProduct;
  }

  /// Deletes a product by ID and updates the in-memory cache.
  Future<bool> deleteProduct(int id) async {
    String token = (await tokenRepository.getToken())!;
    final success = await productRepository.deleteProduct(id, token);

    if (success) {
      // Remove the product from the in-memory cache
      _cachedProducts.removeWhere(
        (prod) => prod.id == id,
      );
    }
    return success;
  }
}
