import 'package:manage_hive/repositories/token_repository.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';

// NOTE: Ensure CustomerRepository and TokenRepository are imported correctly.

class CustomerService {
  final CustomerRepository customerRepository;
  final TokenRepository tokenRepository;
  // Initialize in-memory cache for customers
  List<Customer> _cachedCustomers = List.empty(growable: true);

  CustomerService({
    required this.customerRepository,
    required this.tokenRepository,
  });

  /// Creates a new customer and returns the created Customer object if successful.
  /// Updates the in-memory cache with the newly created customer.
  Future<Customer?> createCustomer(Customer customer) async {
    String token = (await tokenRepository.getToken())!;
    // The backend returns the created Customer object directly.
    final createdCustomer =
        await customerRepository.createCustomer(customer, token);

    if (createdCustomer != null) {
      _cachedCustomers.add(createdCustomer);
    }
    return createdCustomer;
  }

  /// Retrieves all customers for the current user and caches them in RAM.
  Future<List<Customer>> getAllCustomers() async {
    String token = (await tokenRepository.getToken())!;
    final customers = await customerRepository.getAllCustomers(token);
    _cachedCustomers = customers; // Overwrite cache with fresh data
    return customers;
  }

  /// Returns the list of cached customers.
  List<Customer> get cachedCustomers => _cachedCustomers;

  /// Retrieves a specific customer by ID.
  /// First checks the in-memory cache before making a network request.
  Future<Customer?> getCustomer(int id) async {
    // Try finding in cache first
    try {
      return _cachedCustomers.firstWhere((cust) => cust.id == id);
    } catch (_) {
      // If not in cache, fetch from API.
      String token = (await tokenRepository.getToken())!;
      final fetchedCustomer =
          await customerRepository.getCustomer(id, token);

      // If fetched from API, update cache for next time
      if (fetchedCustomer != null) {
        _cachedCustomers.add(fetchedCustomer);
      }
      return fetchedCustomer;
    }
  }

  /// Updates an existing customer and updates the in-memory cache.
  Future<Customer?> updateCustomer(int id, Customer customer) async {
    String token = (await tokenRepository.getToken())!;
    final updatedCustomer =
        await customerRepository.updateCustomer(id, customer, token);

    if (updatedCustomer != null) {
      // Find and replace the old customer in the cache
      final index = _cachedCustomers.indexWhere((cust) => cust.id == id);
      if (index != -1) {
        _cachedCustomers[index] = updatedCustomer;
      }
    }
    return updatedCustomer;
  }

  /// Deletes a customer by ID and updates the in-memory cache.
  Future<bool> deleteCustomer(int id) async {
    String token = (await tokenRepository.getToken())!;
    final success = await customerRepository.deleteCustomer(id, token);

    if (success) {
      // Remove the customer from the in-memory cache
      _cachedCustomers.removeWhere(
        (cust) => cust.id == id,
      );
    }
    return success;
  }
}
