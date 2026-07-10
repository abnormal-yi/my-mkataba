import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/user_model.dart';
import 'rider/rider_dashboard.dart';
import 'owner/owner_dashboard.dart';
import 'admin/admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtl = TextEditingController(text: 'john@mkataba.tz');
  final _pwdCtl = TextEditingController(text: '1234');
  String? _error;

  void _login() {
    final user = DbHelper.getUserByEmail(_emailCtl.text.trim());
    if (user == null) { setState(() => _error = 'Email haipo kwenye system'); return; }
    if (user.password != _pwdCtl.text) { setState(() => _error = 'Password si sahihi'); return; }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => _getDashboard(user)));
  }

  Widget _getDashboard(UserModel user) {
    switch (user.role) {
      case 'rider': return RiderDashboard(user: user);
      case 'owner': return OwnerDashboard(user: user);
      case 'admin': return AdminDashboard(user: user);
      default: return LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C3FC5), Color(0xFFA78BFA)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(child: Text('M', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900))),
              ),
              const SizedBox(height: 16),
              const Text('My Mkataba', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Boda Boda Contract Manager', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailCtl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pwdCtl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outlined)),
              ),
              if (_error != null) Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: FilledButton(onPressed: _login, child: const Text('Sign In', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(height: 16),
              const Text('Demo: john@mkataba.tz / 1234', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
            ]),
          ),
        ),
      ),
    );
  }
}
