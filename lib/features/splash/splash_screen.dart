import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (!state.isChecking && mounted) {
        final role = state.user?.role;
        if (role == null) {
          context.go('/login/rider');
        } else {
          context.go('/${role.name}');
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.purple,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', height: 80, width: 80,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                const SizedBox(height: 16),
                const Text('Mkataba', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: -0.5,
                )),
                const SizedBox(height: 8),
                Text('Boda Contract Management', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.8),
                )),
              ],
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 48),
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
