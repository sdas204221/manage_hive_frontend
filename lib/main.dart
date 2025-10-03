import 'package:flutter/material.dart';
import 'package:manage_hive/providers/backup_provider.dart';
import 'package:manage_hive/providers/customer_provider.dart';
import 'package:manage_hive/providers/invoice_provider.dart';
import 'package:manage_hive/providers/product_provider.dart';
import 'package:manage_hive/providers/user_profile_provider.dart';
import 'package:manage_hive/providers/user_provider.dart';
import 'package:manage_hive/repositories/backup_repository.dart';
import 'package:manage_hive/repositories/customer_repository.dart';
import 'package:manage_hive/repositories/invoice_repository.dart';
import 'package:manage_hive/repositories/product_repository.dart';
import 'package:manage_hive/repositories/user_repository.dart';
import 'package:manage_hive/repositories/user_repository_admin.dart';
import 'package:manage_hive/services/backup_service.dart';
import 'package:manage_hive/services/customer_service.dart';
import 'package:manage_hive/services/invoice_service.dart';
import 'package:manage_hive/services/product_service.dart';
import 'package:manage_hive/services/user_profile_service.dart';
import 'package:manage_hive/services/user_service.dart';
import 'package:provider/provider.dart';
import 'routes/router.dart';
import 'providers/admin_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/token_repository.dart';
import 'services/admin_service.dart';

void main() {
  // Initialize repositories and services
  final authRepository = AuthRepository();
  final tokenRepository = TokenRepository();
  final userRepositoryAdmin = UserRepositoryAdmin();
  final userRepository = UserRepository();
  final invoiceRepository = InvoiceRepository();
  final adminService = AdminService(
    authRepository: authRepository,
    tokenRepository: tokenRepository,
    userRepository: userRepositoryAdmin,
  );
  final BackupRepository backupRepository = BackupRepository();
  final CustomerRepository customerRepository = CustomerRepository();
  final ProductRepository productRepository=ProductRepository();


  final invoiceService = InvoiceService(
    invoiceRepository: invoiceRepository,
    tokenRepository: tokenRepository,
  );
  final userService = UserService(
    authRepository: authRepository,
    tokenRepository: tokenRepository,
  );
  final userProfileService = UserProfileService(
    userRepository: userRepository,
    tokenRepository: tokenRepository,
  );
  final BackupService backupService = BackupService(
    backupRepository: backupRepository,
    tokenRepository: tokenRepository,
  );

  final CustomerService customerService = CustomerService(
    customerRepository: customerRepository,
    tokenRepository: tokenRepository,
  );
final ProductService productService=ProductService(productRepository: productRepository, tokenRepository: tokenRepository);


  final adminProvider = AdminProvider(adminService: adminService);
  final userProvider = UserProvider(
    userService: userService,
    tokenRepository: tokenRepository,
  );
  final invoiceProvider = InvoiceProvider(invoiceService: invoiceService);
  final userProfileProvider = UserProfileProvider(
    userProfileService: userProfileService,
  );
  final BackupProvider backupProvider = BackupProvider(
    backupService: backupService,
  );
  final CustomerProvider customerProvider=CustomerProvider(customerService: customerService);
  final ProductProvider productProvider=ProductProvider(productService: productService);


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => adminProvider),
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => invoiceProvider),
        ChangeNotifierProvider(create: (_) => userProfileProvider),
        ChangeNotifierProvider(create: (_) => backupProvider),
        ChangeNotifierProvider(create: (_) => customerProvider),
        ChangeNotifierProvider(create: (_) => productProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Manage Hive',
      routerConfig: AppRouter.router,
    );
  }
}
