import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manage_hive/models/product.dart';
import '../config/app_config.dart';

class ProductRepository {
  final String _base = "${AppConfig.baseUrl}/api";
  Map<String, String> _headers(String token) => {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

  /// Retrieves a single product by ID.
  Future<Product?> getProduct(int id, String token) async {
    final response = await http.get(
      Uri.parse("$_base/product/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Retrieves all products associated with the authenticated user.
  Future<List<Product>> getAllProducts(String token) async {
    final response = await http.get(
      Uri.parse("$_base/products"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  /// Creates a new product. Returns the created Product object.
  Future<Product?> createProduct(Product product, String token) async {
    final response = await http.post(
      Uri.parse("$_base/product"),
      headers: _headers(token),
      body: jsonEncode(product.toJson()),
    );
    // Backend returns the created object, status is likely 200 OK or 201 Created.
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Updates an existing product by ID.
  Future<Product?> updateProduct(
      int id, Product product, String token) async {
    final response = await http.patch(
      Uri.parse("$_base/product/$id"),
      headers: _headers(token),
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Deletes a product by ID.
  Future<bool> deleteProduct(int id, String token) async {
    final response = await http.delete(
      Uri.parse("$_base/product/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    // Backend returns void, expecting 200 OK or 204 No Content for success.
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
