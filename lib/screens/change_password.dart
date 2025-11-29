import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _oldCtrl = TextEditingController();
  final TextEditingController _newCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _loading = false;

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

  Future<void> _change() async {
    final u = _userCtrl.text.trim();
    final oldP = _oldCtrl.text;
    final newP = _newCtrl.text;
    final confirm = _confirmCtrl.text;
    if (u.isEmpty || oldP.isEmpty || newP.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }
    if (newP != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _loading = true);
    final users = await _readUsers();
    final stored = users[u];
    if (stored == null || stored != oldP) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid username or old password')));
      return;
    }
    users[u] = newP;
    await _writeUsers(users);
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 8),
          TextField(controller: _oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Old password')),
          const SizedBox(height: 8),
          TextField(controller: _newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
          const SizedBox(height: 8),
          TextField(controller: _confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm new password')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loading ? null : _change, child: _loading ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Change Password')),
        ]),
      ),
    );
  }
}