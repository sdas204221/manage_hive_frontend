import 'package:manage_hive/repositories/token_repository.dart';
import '../models/invoice.dart';
import '../repositories/invoice_repository.dart';
import 'dart:typed_data';

class InvoiceService {
  final InvoiceRepository invoiceRepository;
  final TokenRepository tokenRepository;
  List<Invoice> _cachedInvoices = List.empty();

  InvoiceService({
    required this.invoiceRepository,
    required this.tokenRepository,
  });

  /// Creates a new invoice and returns the generated invoice number if successful.
  /// Updates the in-memory cache with the newly created invoice.
  Future<int?> createInvoice(Invoice invoice) async {
    String token = (await tokenRepository.getToken())!;
    final invoiceNumber = await invoiceRepository.createInvoice(invoice, token);
    if (invoiceNumber != null) {
      // Optionally, fetch the complete invoice with generated fields
      final createdInvoice = await getInvoiceJson(invoiceNumber);
      if (createdInvoice != null) {
        _cachedInvoices.add(createdInvoice);
      }
    }
    return invoiceNumber;
  }

  /// Retrieves all invoices for the current user and caches them in RAM.
  Future<List<Invoice>> getAllInvoices() async {
    String token = (await tokenRepository.getToken())!;
    final invoices = await invoiceRepository.getAllInvoices(token);
    _cachedInvoices = invoices;
    return invoices;
  }

  /// Returns the list of cached invoices.
  List<Invoice> get cachedInvoices => _cachedInvoices;

  /// Retrieves a specific invoice by ID.
  /// First checks the in-memory cache before making a network request.
  Future<Invoice?> getInvoiceJson(int id) async {
    String token = (await tokenRepository.getToken())!;
    try {
      //final cachedInvoice =_cachedInvoices.firstWhere((inv) => inv.invoiceNumber == id);
      Invoice? cachedInvoice;
      for (Invoice inv in _cachedInvoices) {
        if (inv.invoiceNumber == id) {
          cachedInvoice = inv;
          break;
        }
      }
      return cachedInvoice;
    } catch (_) {
      // If not in cache, fetch from API.
      return await invoiceRepository.getInvoiceJson(id, token);
    }
  }

  /// Retrieves a specific invoice as a PDF (returns an http.Response).
 Future<Uint8List?> getInvoicePdf(int id) async {
  String token = (await tokenRepository.getToken())!;
  final response = await invoiceRepository.getInvoicePdf(id, token);
  return response?.bodyBytes;
}

  /// Deletes a given invoice and updates the in-memory cache.
  Future<bool> deleteInvoice(Invoice invoice) async {
    String token = (await tokenRepository.getToken())!;
    final success = await invoiceRepository.deleteInvoice(invoice, token);
    if (success) {
      _cachedInvoices.removeWhere(
        (inv) => inv.invoiceNumber == invoice.invoiceNumber,
      );
    }
    return success;
  }
}
