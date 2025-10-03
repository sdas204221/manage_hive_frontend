import 'package:flutter/material.dart';
import 'package:manage_hive/models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService productService;

  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Product> get products => _products;

  ProductProvider({required this.productService});

  /// Helper to manage loading state and error messages consistently.
  void _setLoading(bool value, {String? error}) {
    _isLoading = value;
    _errorMessage = error;
    notifyListeners();
  }

  /// Retrieves all products and updates the local list.
  Future<void> fetchProducts() async {
    _setLoading(true);

    try {
      _products = await productService.getAllProducts();
    } catch (e) {
      _setLoading(false, error: e.toString());
      return;
    }
    _setLoading(false);
  }

  /// Creates a new product, updates the service cache, and refreshes the local list.
  Future<void> createProduct(Product product) async {
    _setLoading(true);

    try {
      final createdProduct = await productService.createProduct(product);
      if (createdProduct != null) {
        // Since the service manages the cache, we add the created item locally.
        _products.add(createdProduct);
      }
    } catch (e) {
      _setLoading(false, error: e.toString());
      return;
    }
    _setLoading(false);
  }

  /// Updates an existing product and refreshes the local list item.
  Future<void> updateProduct(int id, Product product) async {
    _setLoading(true);

    try {
      final updatedProduct =
          await productService.updateProduct(id, product);
      if (updatedProduct != null) {
        // Find and replace the item in the provider's list
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
      }
    } catch (e) {
      _setLoading(false, error: e.toString());
      return;
    }
    _setLoading(false);
  }

  /// Deletes a product by ID and removes it from the local list.
  Future<void> deleteProduct(int id) async {
    _setLoading(true);

    try {
      final success = await productService.deleteProduct(id);
      if (success) {
        // Remove from the provider's list
        _products.removeWhere((p) => p.id == id);
      }
    } catch (e) {
      _setLoading(false, error: e.toString());
      return;
    }
    _setLoading(false);
  }

  /// Helper method to look up a product from the currently cached list.
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((prod) => prod.id == id);
    } catch (_) {
      return null;
    }
  }
}
