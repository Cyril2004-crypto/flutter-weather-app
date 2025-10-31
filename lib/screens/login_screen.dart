import 'package:flutter/material.dart';

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
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a username')));
      return;
    }
    await widget.onLogin(username);
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
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.wb_sunny, size: 44, color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Welcome,', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Sign in to view personalized weather', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
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
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login_outlined),
                        label: const Text('Login'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 6,
                        ),
                        onPressed: _handleLogin,
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
                  TextButton(
                    onPressed: () {
                      final sample = 'cyril';
                      _usernameController.text = sample;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample username filled')));
                    },
                    child: const Text('Try demo account'),
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
