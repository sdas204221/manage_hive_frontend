import 'package:flutter/material.dart';
import 'package:manage_hive/models/invoice.dart';
import 'package:manage_hive/models/sales_line.dart';
import 'package:manage_hive/providers/invoice_provider.dart';
import 'package:manage_hive/providers/user_profile_provider.dart';
import 'package:manage_hive/providers/user_provider.dart';
import 'package:manage_hive/repositories/auth_repository.dart';
import 'package:manage_hive/repositories/invoice_repository.dart';
import 'package:manage_hive/repositories/token_repository.dart';
import 'package:manage_hive/repositories/user_repository.dart';
import 'package:manage_hive/services/invoice_service.dart';
import 'package:manage_hive/services/user_profile_service.dart';
import 'package:manage_hive/services/user_service.dart';

void main() {
  runApp(const MaterialApp(
    home: TestProvidersPage(),
  ));
}

class TestProvidersPage extends StatefulWidget {
  const TestProvidersPage({super.key});

  @override
  State<TestProvidersPage> createState() => _TestProvidersPageState();
}

class _TestProvidersPageState extends State<TestProvidersPage> {
  final buffer = StringBuffer();
  String result = 'Running tests...';

  @override
  void initState() {
    super.initState();
    runTests();
  }

  Future<void> runTests() async {
    final InvoiceRepository invoiceRepository = InvoiceRepository();
    final TokenRepository tokenRepository = TokenRepository();
    final UserRepository userRepository = UserRepository();
    final AuthRepository authRepository = AuthRepository();

    final invoiceService = InvoiceService(
      invoiceRepository: invoiceRepository,
      tokenRepository: tokenRepository,
    );
    final userProfileService = UserProfileService(
      userRepository: userRepository,
      tokenRepository: tokenRepository,
    );
    final userService = UserService(
      authRepository: authRepository,
      tokenRepository: tokenRepository,
    );

    final invoiceProvider = InvoiceProvider(invoiceService: invoiceService);
    await invoiceProvider.fetchInvoices();
    buffer.writeln('🧾 InvoiceProvider → fetchInvoices()');
    buffer.writeln('  isLoading: ${invoiceProvider.isLoading}');
    buffer.writeln('  errorMessage: ${invoiceProvider.errorMessage}');
    buffer.writeln('  invoices count: ${invoiceProvider.invoices.length}');

    final newInvoice = Invoice(
      customerName: 'John Doe',
      customerAddress: '1234 Elm Street',
      issueDate: DateTime.now(),
      paymentMethod: 'Credit Card',
      paymentTerms: 'Net 30',
      discount: 10.0,
      salesLines: [
        SalesLine(description: 'Chair', quantity: 2, unitPrice: 1500.0),
        SalesLine(description: 'Lamp', quantity: 1, unitPrice: 700.0),
      ],
      subtotal: 3700.0,
      totalAmount: 3330.0,
    );

    await invoiceProvider.createInvoice(newInvoice);
    buffer.writeln('\n🧾 InvoiceProvider → createInvoice()');
    buffer.writeln('  invoices count: ${invoiceProvider.invoices.length}');

    await invoiceProvider.deleteInvoice(newInvoice);
    buffer.writeln('\n🧾 InvoiceProvider → deleteInvoice()');
    buffer.writeln('  invoices count: ${invoiceProvider.invoices.length}');

    final userProfileProvider = UserProfileProvider(userProfileService: userProfileService);
    await userProfileProvider.fetchUserProfile();
    buffer.writeln('\n👤 UserProfileProvider → fetchUserProfile()');
    buffer.writeln('  user: ${userProfileProvider.user?.username}');

    final updatedUser = userProfileProvider.user?.copyWith(businessName: 'Updated Biz');
    if (updatedUser != null) {
      await userProfileProvider.updateUserProfile(updatedUser);
      buffer.writeln('\n👤 UserProfileProvider → updateUserProfile()');
      buffer.writeln('  businessName: ${userProfileProvider.user?.businessName}');
    }

    await userProfileProvider.deleteUserProfile();
    buffer.writeln('\n👤 UserProfileProvider → deleteUserProfile()');
    buffer.writeln('  user: ${userProfileProvider.user}');

    final userProvider = UserProvider(userService: userService, tokenRepository: tokenRepository);
    await userProvider.login("user5", "1111");
    buffer.writeln('\n👥 UserProvider → login()');
    buffer.writeln('  errorMessage: ${userProvider.errorMessage}');

    await userProvider.logout();
    buffer.writeln('\n👥 UserProvider → logout()');

    setState(() => result = buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Test Output')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(result),
      ),
    );
  }
}
