import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/auth_provider.dart';

final Map<String, UserRole> _demoAccounts = {
  'rider@mkataba.com': UserRole.rider,
  'owner@mkataba.com': UserRole.owner,
  'admin@mkataba.com': UserRole.admin,
};

class LoginScreen extends ConsumerStatefulWidget {
  final String role;
  const LoginScreen({super.key, this.role = 'rider'});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  final Map<String, String> _demoPasswords = {
    'rider@mkataba.com': 'rider123',
    'owner@mkataba.com': 'owner123',
    'admin@mkataba.com': 'admin123',
  };

  Map<String, User> _demoUsers = {
    'rider@mkataba.com': User(id: 'rider-001', name: 'John', email: 'rider@mkataba.com', role: UserRole.rider),
    'owner@mkataba.com': User(id: 'owner-001', name: 'Alinda Rwegasila', email: 'owner@mkataba.com', role: UserRole.owner),
    'admin@mkataba.com': User(id: 'admin-001', name: 'Admin', email: 'admin@mkataba.com', role: UserRole.admin),
  };

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailC.text.trim().toLowerCase();
    final password = _passwordC.text;
    final userData = _demoUsers[email];

    if (userData != null) {
      final expectedPassword = _demoPasswords[email]!;
      if (password != expectedPassword) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password')));
        return;
      }
      ref.read(authProvider.notifier).setUser(userData, 'demo-token');
      context.go('/${userData.role.name}');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account not found. Please contact admin.')));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, state) {
      if (state.user != null && !state.isLoading && mounted) {
        context.go('/${state.user!.role.name}');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.purpleLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('${widget.role.toUpperCase()} Login',
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.purpleLight)),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Image.asset('assets/logo.png', height: 56, width: 56,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
              const SizedBox(height: 8),
              const Center(child: Text('Mkataba', style: TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary))),
              const SizedBox(height: 32),
              const Text('Welcome Back', style: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 4),
              const Text('Sign in to your account', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: AppColors.muted)),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailC,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _input('Email', 'you@example.com'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordC,
                      obscureText: _obscure,
                      decoration: _input('Password', 'Enter password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.muted, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your password' : null,
                    ),
                    if (authState.error != null) ...[
                      const SizedBox(height: 12),
                      Text(authState.error!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.error)),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _handleLogin,
                        child: authState.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Don't have an account? Register", style: TextStyle(fontSize: 13, color: AppColors.muted)),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    const Text('Demo Accounts', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Text('rider@mkataba.com / owner@mkataba.com / admin@mkataba.com',
                      style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                    Text('Password: rider123 / owner123 / admin123',
                      style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label, String hint) {
    return InputDecoration(
      labelText: label, hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.purpleLight, width: 2)),
      filled: true, fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
