import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manage_hive/providers/user_provider.dart';
import 'package:provider/provider.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(UserProvider userProvider) async {
    await userProvider.login(
      _usernameController.text,
      _passwordController.text,
    );
    if (userProvider.errorMessage == null) {
      // Navigate to the admin home/dashboard after a successful login.
      context.go('/home');
    } else {
      // Show error message if login fails.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Hive')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          width: isPortrait ? size.width * 0.9 : size.width * 0.5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'User Login',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        userProvider.isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () => _login(userProvider),
                                child: const Text('Login'),
                              ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            context.go('/admin_login');
                          },
                          child: const Text("Go to Admin Login"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
