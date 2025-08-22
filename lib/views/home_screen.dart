// All your imports remain unchanged
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:manage_hive/providers/backup_provider.dart';
import 'package:manage_hive/providers/user_profile_provider.dart';
import 'package:manage_hive/providers/user_provider.dart';
import 'package:manage_hive/views/home_screen_wrapper.dart';
import 'package:manage_hive/views/invoice_form_screen.dart';
import 'package:manage_hive/views/invoice_list_screen.dart';
import 'package:provider/provider.dart';

import '../utils/downloader.dart';

// Edit User Dialog (No changes)
Future<void> showEditUserDialog(BuildContext context) async {
  final userProvider = Provider.of<UserProfileProvider>(context, listen: false);
  final user = userProvider.user;

  if (user == null) return;

  final businessNameController = TextEditingController(
    text: user.businessName ?? '',
  );
  final addressController = TextEditingController(text: user.address ?? '');
  final phoneController = TextEditingController(text: user.phone ?? '');
  final emailController = TextEditingController(text: user.email ?? '');
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit User Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: businessNameController,
                decoration: const InputDecoration(labelText: 'Business Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = passwordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (password.isNotEmpty && password != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              final updatedUser = user.copyWith(
                businessName:
                    businessNameController.text.isNotEmpty
                        ? businessNameController.text
                        : null,
                address:
                    addressController.text.isNotEmpty
                        ? addressController.text
                        : null,
                phone:
                    phoneController.text.isNotEmpty
                        ? phoneController.text
                        : null,
                email:
                    emailController.text.isNotEmpty
                        ? emailController.text
                        : null,
                password: password.isNotEmpty ? password : null,
              );

              userProvider.updateUserProfile(updatedUser);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

// Home Widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _dialogShown = false;
  bool _isBackingUp = false;
  bool isReportDownloading = false;
  @override
  void initState() {
    super.initState();
    _checkUserDetails();
  }

  String _formattedDateTime(DateTime dateTime) {
    return DateFormat('yyyy_MM_dd_HH_mm_ss').format(dateTime);
  }

  void _checkUserDetails() async {
    final profileProvider = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    );
    await profileProvider.fetchUserProfile();
    if (profileProvider.shouldShowEditOnStartup && !_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showEditUserDialog(context);
        _dialogShown = true;
      });
    }
  }

  void _logout(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;

    return HomeScreenWrapper(
      isAnyLoading:
          Provider.of<UserProvider>(context, listen: true).isLoading ||
          Provider.of<UserProfileProvider>(context, listen: true).isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            isReportDownloading
                ? const CircularProgressIndicator()
                : IconButton(
                  tooltip: "Download Sales Report",
                  icon: const Icon(Icons.insert_chart_outlined),
                  onPressed: () async {
                    setState(() {
                      isReportDownloading = true;
                    });

                    final reportBytes =
                        await Provider.of<BackupProvider>(
                          context,
                          listen: false,
                        ).getSalesCsvBackup(); // CSV Uint8List

                    if (reportBytes != null) {
                      try {
                        await download(
                          reportBytes,
                          'sales_report_${_formattedDateTime(DateTime.now())}.csv',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report download complete!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to download: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Something went wrong.')),
                      );
                    }

                    setState(() {
                      isReportDownloading = false;
                    });
                  },
                ),
            _isBackingUp
                ? const CircularProgressIndicator()
                : IconButton(
                  tooltip: "Download Backup",
                  icon: const Icon(Icons.cloud_download),
                  onPressed: () async {
                    // The download action is mocked; no behavior is defined.
                    setState(() {
                      _isBackingUp = true;
                    });
                    final backupBytes =
                        await Provider.of<BackupProvider>(
                          context,
                          listen: false,
                        ).getUserBackup(); // or whatever ID

                    if (backupBytes != null) {
                      try {
                        await download(
                          backupBytes,
                          'backup_${_formattedDateTime(DateTime.now())}.json',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Backup complete!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Somthing went wrong.')),
                      );
                    }
                    setState(() {
                      _isBackingUp = false;
                    });
                  },
                ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => showEditUserDialog(context),
              tooltip: 'Edit Details',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          ],
        ),
        body:
            screenWidth < breakpoint
                ? const _NarrowLayout()
                : const _WideLayout(),
      ),
    );
  }
}

// No changes to layout widgets
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children:  [
          TabBar(tabs: [Tab(text: 'Add Invoice'), Tab(text: 'Invoices')]),
          Expanded(
            child: TabBarView(
              children: [FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: InvoiceFormScreen(),
        ), InvoiceListScreen()],
            ),
          ),
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double listMinWidth = 300;
    final double listMaxWidth = screenWidth * 0.30;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: InvoiceFormScreen(),
        ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: listMinWidth,
            maxWidth: listMaxWidth,
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: InvoiceListScreen(),
          ),
        ),
      ],
    );
  }
}
