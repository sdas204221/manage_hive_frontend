import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/customer.dart'; // Imports the Customer model

class CustomerRepository {
  final String _base = "${AppConfig.baseUrl}/api";
  Map<String, String> _headers(String token) => {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

  /// Retrieves a single customer by ID.
  Future<Customer?> getCustomer(int id, String token) async {
    final response = await http.get(
      Uri.parse("$_base/customer/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Retrieves all customers associated with the authenticated user.
  Future<List<Customer>> getAllCustomers(String token) async {
    final response = await http.get(
      Uri.parse("$_base/customers"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Customer.fromJson(e)).toList();
    }
    return [];
  }

  /// Creates a new customer. Returns the created Customer object.
  Future<Customer?> createCustomer(Customer customer, String token) async {
    final response = await http.post(
      Uri.parse("$_base/customer"),
      headers: _headers(token),
      body: jsonEncode(customer.toJson()),
    );
    // Backend returns the created object, status is likely 200 OK or 201 Created.
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Customer.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Updates an existing customer by ID.
  Future<Customer?> updateCustomer(
      int id, Customer customer, String token) async {
    final response = await http.patch(
      Uri.parse("$_base/customer/$id"),
      headers: _headers(token),
      body: jsonEncode(customer.toJson()),
    );
    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Deletes a customer by ID.
  Future<bool> deleteCustomer(int id, String token) async {
    final response = await http.delete(
      Uri.parse("$_base/customer/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    // Backend returns void, expecting 200 OK or 204 No Content for success.
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
