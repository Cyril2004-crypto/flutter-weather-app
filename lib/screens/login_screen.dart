import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password.dart';

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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AnimationController _animController;
  bool _obscure = true;
  bool _isRegister = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('users') ?? '{}';
    final Map<String, dynamic> m = json.decode(s) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> _writeUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users', json.encode(users));
  }

  Future<void> _handleAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter username and password')));
      return;
    }

    setState(() => _loading = true);
    final users = await _readUsers();

    if (_isRegister) {
      if (users.containsKey(username)) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username already exists')));
        return;
      }
      users[username] = password;
      await _writeUsers(users);
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered successfully')));
      await widget.onLogin(username);
    } else {
      final stored = users[username];
      setState(() => _loading = false);
      if (stored == null || stored != password) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid username or password')));
        return;
      }
      await widget.onLogin(username);
    }
  }

  void _fillDemo() {
    _usernameController.text = 'cyril';
    _passwordController.text = 'password';
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample credentials filled')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [Colors.indigo.shade900, Colors.blueGrey.shade900]
                : [Colors.lightBlue.shade300, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut)),
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.wb_sunny, size: 44, color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(_isRegister ? 'Create account' : 'Welcome,', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(_isRegister ? 'Register a new account' : 'Sign in to view personalized weather',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: widget.isDarkMode ? Colors.white12 : Colors.white,
                      prefixIcon: const Icon(Icons.person),
                      hintText: 'Enter username',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _handleAuth(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: widget.isDarkMode ? Colors.white12 : Colors.white,
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _handleAuth(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login_outlined),
                        label: Text(_isRegister ? 'Register' : 'Login'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 6,
                        ),
                        onPressed: _loading ? null : _handleAuth,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Toggle theme',
                        icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                        onPressed: widget.toggleTheme,
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _fillDemo,
                        child: const Text('Try demo account'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => setState(() => _isRegister = !_isRegister),
                        child: Text(_isRegister ? 'Have an account? Login' : 'Create an account'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                        child: const Text('Change password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
