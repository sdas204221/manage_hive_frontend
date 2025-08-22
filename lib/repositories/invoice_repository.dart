import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/invoice.dart';

class InvoiceRepository {
  final String _base = "${AppConfig.baseUrl}/api";

  Future<int?> createInvoice(Invoice invoice, String token) async {
    // invoice.issueDate!=invoice.issueDate!.subtract(Duration(hours: 5,minutes: 30));
    final response = await http.post(
      Uri.parse("$_base/invoice"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(invoice.toJson()),
    );
    return response.statusCode == 201 ? jsonDecode(response.body) : null;
  }

  Future<List<Invoice>> getAllInvoices(String token) async {
    final response = await http.get(
      Uri.parse("$_base/invoices"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      List<Invoice> invoices = [];
      for (var e in data) {
        invoices.add(Invoice.fromJson(e));
      }
      //print(data);

      return invoices;
    }
    return [];
  }

  Future<Invoice?> getInvoiceJson(int id, String token) async {
    final response = await http.get(
      Uri.parse("$_base/invoice/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return Invoice.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<http.Response?> getInvoicePdf(int id, String token) async {
    final response = await http.get(
      Uri.parse("$_base/invoice/$id"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/pdf"},
    );
    return response.statusCode == 200 ? response : null;
  }

  Future<bool> deleteInvoice(Invoice invoice, String token) async {
    final response = await http.delete(
      Uri.parse("$_base/invoice"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(invoice.toJson()),
    );
    return response.statusCode == 204;
  }
}
