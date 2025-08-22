// lib/service_test.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:manage_hive/config/app_config.dart';
import 'package:manage_hive/models/invoice.dart';
import 'package:manage_hive/models/sales_line.dart';
import 'package:manage_hive/models/user.dart';
import 'package:manage_hive/repositories/auth_repository.dart';
import 'package:manage_hive/repositories/invoice_repository.dart';
import 'package:manage_hive/repositories/token_repository.dart';
import 'package:manage_hive/repositories/user_repository.dart';
import 'package:manage_hive/services/invoice_service.dart';
import 'package:manage_hive/services/user_profile_service.dart';
import 'package:manage_hive/services/user_service.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate repositories
  final tokenRepository = TokenRepository();
  final authRepository = AuthRepository();
  final invoiceRepository = InvoiceRepository();
  final userRepository = UserRepository();

  // Instantiate services
  final userService = UserService(
    authRepository: authRepository,
    tokenRepository: tokenRepository,
  );
  final invoiceService = InvoiceService(
    invoiceRepository: invoiceRepository,
    tokenRepository: tokenRepository,
  );
  final userProfileService = UserProfileService(
    userRepository: userRepository,
    tokenRepository: tokenRepository,
  );

  // Comprehensive Test Report String
  StringBuffer report = StringBuffer();
  report.writeln('==== SERVICE TEST REPORT ====');
  report.writeln('Base URL: ${AppConfig.baseUrl}');
  report.writeln('');

  // --- Test 1: User Login ---
  report.writeln('TEST 1: User Login');
  try {
    // Replace with valid test credentials
    String testUsername = 'user5';
    String testPassword = '1111';
    await userService.loginUser(testUsername, testPassword);
    String? token = await tokenRepository.getToken();
    if (token != null) {
      report.writeln('User login successful. Token: $token');
    } else {
      report.writeln('User login failed. No token stored.');
    }
  } catch (e) {
    report.writeln('User login error: $e');
  }
  report.writeln('');

  // --- Test 2: Fetch User Profile ---
  report.writeln('TEST 2: Fetch User Profile');
  try {
    User? user = await userProfileService.fetchUser();
    if (user != null) {
      report.writeln('Fetched user: ${user.username}');
      report.writeln('Business Name: ${user.businessName}');
      report.writeln('Address: ${user.address}');
      report.writeln('Phone: ${user.phone}');
      report.writeln('Email: ${user.email}');
    } else {
      report.writeln('User profile not found.');
    }
  } catch (e) {
    report.writeln('Error fetching user profile: $e');
  }
  report.writeln('');

  // --- Test 3: Create Invoice ---
  report.writeln('TEST 3: Create Invoice');
  try {
    // Create a sample invoice with test data
    Invoice testInvoice = Invoice(
      invoiceNumber: 0, // Backend will generate the actual number
      customerName: 'Jane Smith',
      customerAddress: '123 Elm Street, Tarakeswar, West Bengal, India',
      issueDate: DateTime.parse('2025-03-25'),
      paymentMethod: 'Credit Card',
      paymentTerms: 'Net 30',
      paymentDate: DateTime.parse('2025-04-24'),
      discount: 10.0,
      salesLines: [
        SalesLine(
          description: 'Premium Wooden Chair',
          quantity: 2,
          unitPrice: 1500.0,
        ),
        SalesLine(
          description: 'Glass Coffee Table',
          quantity: 1,
          unitPrice: 4500.0,
        ),
        SalesLine(description: 'Floor Lamp', quantity: 3, unitPrice: 800.0),
      ],
      subtotal: 100.0,
      totalAmount: 100.0,
    );
    int? createdInvoiceNumber = await invoiceService.createInvoice(testInvoice);
    if (createdInvoiceNumber != null) {
      report.writeln(
        'Invoice created successfully with number: $createdInvoiceNumber',
      );
    } else {
      report.writeln('Failed to create invoice.');
    }
  } catch (e) {
    report.writeln('Error creating invoice: $e');
  }
  report.writeln('');

  // --- Test 4: Get All Invoices ---
  report.writeln('TEST 4: Get All Invoices');
  try {
    List<Invoice> invoices = await invoiceService.getAllInvoices();
    report.writeln('Fetched ${invoices.length} invoices:');
    for (Invoice inv in invoices) {
      report.writeln(
        ' - Invoice #${inv.invoiceNumber}: ${inv.customerName} | Issued on: ${inv.issueDate}',
      );
    }
  } catch (e) {
    report.writeln('Error fetching invoices: $e');
  }
  report.writeln('');

  // --- Test 5: Get Single Invoice (JSON) ---
  report.writeln('TEST 5: Get Single Invoice (JSON)');
  try {
    // Adjust invoice number to one known to exist; using the first invoice in cache if available.
    if (invoiceService.cachedInvoices.isNotEmpty) {
      int? invoiceId = invoiceService.cachedInvoices.first.invoiceNumber;
      Invoice? invoice = await invoiceService.getInvoiceJson(invoiceId!);
      if (invoice != null) {
        report.writeln('Fetched Invoice #$invoiceId successfully:');
        report.writeln(jsonEncode(invoice.toJson()));
      } else {
        report.writeln('Invoice #$invoiceId not found.');
      }
    } else {
      report.writeln('No cached invoices to test getInvoiceJson.');
    }
  } catch (e) {
    report.writeln('Error fetching single invoice: $e');
  }
  report.writeln('');

  // --- Test 6: Get Invoice as PDF ---
  report.writeln('TEST 6: Get Invoice as PDF');
  try {
    // Adjust invoice number to one known to exist; using first from cache.
    if (invoiceService.cachedInvoices.isNotEmpty) {
      int? invoiceId = invoiceService.cachedInvoices.first.invoiceNumber;
      //invoiceId=31;
      Uint8List? pdfResponse = await invoiceService.getInvoicePdf(
        invoiceId!,
      );
      if (pdfResponse != null) {
        report.writeln(
          'Fetched PDF for Invoice #$invoiceId successfully.',
        );
      } else {
        report.writeln('Failed to fetch PDF for Invoice #$invoiceId.');
      }
    } else {
      report.writeln('No cached invoices to test PDF retrieval.');
    }
  } catch (e) {
    report.writeln('Error fetching invoice PDF: $e');
  }
  report.writeln('');

  // --- Test 7: Delete Invoice ---
  report.writeln('TEST 7: Delete Invoice');
  try {
    // Delete the first invoice from cache (if any)
    if (invoiceService.cachedInvoices.isNotEmpty) {
      Invoice invoiceToDelete = invoiceService.cachedInvoices.first;
      bool deleteSuccess = await invoiceService.deleteInvoice(invoiceToDelete);
      if (deleteSuccess) {
        report.writeln(
          'Invoice #${invoiceToDelete.invoiceNumber} deleted successfully.',
        );
      } else {
        report.writeln(
          'Failed to delete Invoice #${invoiceToDelete.invoiceNumber}.',
        );
      }
    } else {
      report.writeln('No cached invoices available to delete.');
    }
  } catch (e) {
    report.writeln('Error deleting invoice: $e');
  }
  report.writeln('');
  // --- Test 8: Update User Profile ---
  report.writeln('TEST 8: Update User Profile');
  try {
    User updatedUser = User(
      username: 'user5',
      businessName: 'Updated Hive Enterprises',
      address: 'Newtown, Kolkata, India',
      phone: '9876543210',
      email: 'updated_user5@example.com',
      role: '',
      accountLocked: false,
    );

    bool updateResult = await userProfileService.updateUser(updatedUser);
    if (updateResult) {
      report.writeln('User profile updated successfully.');
      // Fetch again to verify
      User? verifiedUser = await userProfileService.fetchUser();
      if (verifiedUser != null) {
        report.writeln('Verified Updated Profile:');
        report.writeln('Business Name: ${verifiedUser.businessName}');
        report.writeln('Address: ${verifiedUser.address}');
        report.writeln('Phone: ${verifiedUser.phone}');
        report.writeln('Email: ${verifiedUser.email}');
      } else {
        report.writeln('Failed to re-fetch updated user.');
      }
    } else {
      report.writeln('User profile update failed.');
    }
  } catch (e) {
    report.writeln('Error updating user profile: $e');
  }
  report.writeln('');

  // --- Final Report Output ---
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Service Test Report')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            report.toString(),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
    ),
  );
}
