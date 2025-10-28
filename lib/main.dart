import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool _isDarkMode = false;
  bool _isLoggedIn = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _username = prefs.getString('username');
    });
  }

  Future<void> _onLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username);
    setState(() {
      _isLoggedIn = true;
      _username = username;
    });
  }

  Future<void> _onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    setState(() {
      _isLoggedIn = false;
      _username = null;
    });
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = !_isDarkMode);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _isLoggedIn
          ? WeatherScreen(
              username: _username ?? 'User',
              onLogout: _onLogout,
              toggleTheme: _toggleTheme,
            )
          : LoginScreen(
              onLogin: _onLogin,
              isDarkMode: _isDarkMode,
              toggleTheme: _toggleTheme,
            ),
    );
  }
}

// Virtual Identity: AuthWrapper (optional shared widget) — fixed to provide correct params
class AuthWrapper extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const AuthWrapper({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final username = prefs.getString('username');
    setState(() {
      _isLoggedIn = isLoggedIn;
      _username = username;
      _isLoading = false;
    });
  }

  Future<void> _handleLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username);
    setState(() {
      _isLoggedIn = true;
      _username = username;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    setState(() {
      _isLoggedIn = false;
      _username = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isLoggedIn
        ? WeatherScreen(
            username: _username ?? 'User',
            onLogout: _handleLogout,
            toggleTheme: widget.toggleTheme,
          )
        : LoginScreen(
            onLogin: _handleLogin,
            isDarkMode: widget.isDarkMode,
            toggleTheme: widget.toggleTheme,
          );
  }
}
