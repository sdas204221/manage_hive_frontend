import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService invoiceService;

  bool _isLoading = false;
  String? _errorMessage;
  List<Invoice> _invoices = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Invoice> get invoices => _invoices;

  InvoiceProvider({required this.invoiceService});

  Future<void> fetchInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _invoices = await invoiceService.getAllInvoices();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createInvoice(Invoice invoice) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await invoiceService.createInvoice(invoice);
      await fetchInvoices(); // Refresh list after creation
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInvoice(Invoice invoice) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await invoiceService.deleteInvoice(invoice);
      await fetchInvoices(); // Refresh list after deletion
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Uint8List?> getInvoicePdf(int id) async {
    _errorMessage = null;
    notifyListeners();
    Uint8List? pdfBytes;
    try {
      pdfBytes = await invoiceService.getInvoicePdf(id);
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
    return pdfBytes;
  }
}
