import 'package:go_router/go_router.dart';
import 'package:manage_hive/views/Customer_management_screen.dart';
import 'package:manage_hive/views/admin_dashboard.dart';
import 'package:manage_hive/views/home_screen.dart';
import 'package:manage_hive/views/product_management_screen.dart';
import 'package:manage_hive/views/user_login.dart';
import 'package:manage_hive/views/admin_login.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const UserLogin(),
      ),
      GoRoute(
        path: '/admin_login',
        name: 'adminLogin',
        builder: (context, state) => const AdminLogin(),
      ),
      GoRoute(
        path: '/admin_dashboard',
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomerManagementScreen(),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductManagementScreen(),
      ),
    ],
  );
}
