import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_screen.dart';

// Theme 4: Virtual Identity - Login screen with local storage
class LoginScreen extends StatefulWidget {
  final Future<void> Function(String username) onLogin;
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a username')));
      return;
    }
    await widget.onLogin(username);
    // Navigation is handled by main.dart (auth wrapper)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome,'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.toggleTheme,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Enter username'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Login'),
              onPressed: _handleLogin,
            ),
          ],
        ),
      ),
    );
  }
}
