import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:manage_hive/providers/backup_provider.dart';
import 'package:manage_hive/utils/downloader_web.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/user.dart';
import '../providers/admin_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isBackingUp = false;

  String _formattedDateTime(DateTime dateTime) {
    return DateFormat('yyyy_MM_dd_HH_mm_ss').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    // Fetch the list of users when the dashboard loads.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
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
                      ).getAdminBackup(); // or whatever ID

                  if (backupBytes != null) {
                    try {
                      await download(
                        backupBytes,
                        'full_db_backup_${_formattedDateTime(DateTime.now())}.json',
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
            icon: Icon(LucideIcons.keyRound),
            tooltip: "Change Password",
            onPressed: () async {
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder:
                    (context) => MultiPurposeDialog(title: "Change Password"),
              );
              if (result != null) {
                final username = result['username']!;
                final password = result['password']!;
                await adminProvider.changePassword(username, password);
              }
            },
          ),
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await adminProvider.logout();
              // After logout, navigate to the admin login screen
              context.go("/login");
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, String>>(
            context: context,
            builder: (context) => MultiPurposeDialog(title: 'Add User'),
          );
          if (result != null) {
            final username = result['username']!;
            final password = result['password']!;
            await adminProvider.addUser(username, password);
          }
        },
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
      body:
          adminProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async {
                  await adminProvider.fetchUsers();
                },
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 750),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const SizedBox(height: 16),
                        // List of Users
                        ...adminProvider.users.map((User user) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(user.username!),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (user.businessName != null)
                                    Text('Business: ${user.businessName}'),
                                  if (user.email != null)
                                    Text('Email: ${user.email}'),
                                  if (user.phone != null)
                                    Text('Phone: ${user.phone}'),
                                  if (user.address != null)
                                    Text('Address: ${user.address}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(LucideIcons.keyRound),
                                    tooltip: "Change Password",
                                    onPressed: () async {
                                      final result =
                                          await showDialog<Map<String, String>>(
                                            context: context,
                                            builder:
                                                (context) => MultiPurposeDialog(
                                                  title: "Change Password",
                                                  username: user.username,
                                                ),
                                          );
                                      if (result != null) {
                                        final username = result['username']!;
                                        final password = result['password']!;
                                        await adminProvider.changePassword(
                                          username,
                                          password,
                                        );
                                      }
                                    },
                                  ),
                                  // Toggle lock/unlock icon
                                  IconButton(
                                    icon: Icon(
                                      user.accountLocked!
                                          ? LucideIcons.lock
                                          : LucideIcons.unlock,
                                    ),
                                    tooltip:
                                        user.accountLocked!
                                            ? 'Unlock User'
                                            : 'Lock User',
                                    onPressed: () async {
                                      await adminProvider.toggleLock(
                                        user.username!,
                                        user.accountLocked!,
                                      );
                                    },
                                  ),
                                  // Delete user button
                                  IconButton(
                                    icon: const Icon(LucideIcons.trash),
                                    tooltip: 'Delete User',
                                    onPressed: () async {
                                      // Confirm deletion before deleting
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text('Delete User'),
                                              content: Text(
                                                'Are you sure you want to delete ${user.username}?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (confirm == true) {
                                        await adminProvider.deleteUser(
                                          user.username!,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

class MultiPurposeDialog extends StatefulWidget {
  final String title;
  String? username;
  MultiPurposeDialog({super.key, required this.title, this.username});

  @override
  State<MultiPurposeDialog> createState() => _MultiPurposeDialogState();
}

class _MultiPurposeDialogState extends State<MultiPurposeDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _usernameController.text = widget.username ?? "";
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'username': _usernameController.text.trim(),
              'password': _passwordController.text.trim(),
            });
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
