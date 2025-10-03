import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService customerService;

  bool _isLoading = false;
  String? _errorMessage;
  List<Customer> _customers = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Customer> get customers => _customers;

  CustomerProvider({required this.customerService});

  /// Helper to manage loading state and error messages consistently.
  void _setLoading(bool value, {String? error}) {
    _isLoading = value;
    _errorMessage = error;
    notifyListeners();
  }

  /// Retrieves all customers and updates the local list.
  Future<void> fetchCustomers() async {
    _setLoading(true);

    try {
      _customers = await customerService.getAllCustomers();
    } catch (e) {
      _setLoading(false, error: e.toString());
      return;
    }
    _setLoading(false);
  }

  /// Creates a new customer, updates the service cache, and refreshes the local list.
  Future<void> createCustomer(Customer customer) async {
    _setLoading(true);

    try {
      final createdCustomer = await customerService.createCustomer(customer);
      if (createdCustomer != null) {
        // Since the service manages the cache, we add the created item locally.
        _customers.add(createdCustomer);
      }
    } catch (e) {
      _setLoading(false, error: e.toString());
      return;
    }
    _setLoading(false);
  }

  /// Updates an existing customer and refreshes the local list item.
  Future<void> updateCustomer(int id, Customer customer) async {
    _setLoading(true);

    try {
      final updatedCustomer =
          await customerService.updateCustomer(id, customer);
      if (updatedCustomer != null) {
        // Find and replace the item in the provider's list
        final index = _customers.indexWhere((c) => c.id == id);
        if (index != -1) {
          _customers[index] = updatedCustomer;
        }
      }
    } catch (e) {
      _setLoading(false, error: e.toString());
      return;
    }
    _setLoading(false);
  }

  /// Deletes a customer by ID and removes it from the local list.
  Future<void> deleteCustomer(int id) async {
    _setLoading(true);

    try {
      final success = await customerService.deleteCustomer(id);
      if (success) {
        // Remove from the provider's list
        _customers.removeWhere((c) => c.id == id);
      }
    } catch (e) {
      _setLoading(false, error: e.toString());
      return;
    }
    _setLoading(false);
  }

  /// Helper method to look up a customer from the currently cached list.
  Customer? getCustomerById(int id) {
    try {
      return _customers.firstWhere((cust) => cust.id == id);
    } catch (_) {
      return null;
    }
  }
}
