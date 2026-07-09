import 'package:flutter/material.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.red,
        title: const Text('Account Blocked'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: AppColors.redBg, borderRadius: BorderRadius.circular(50)),
                child: const Icon(Icons.block, size: 50, color: AppColors.red),
              ),
              const SizedBox(height: 24),
              const Text('Account Blocked', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text)),
              const SizedBox(height: 12),
              const Text('Your contract has been blocked due to missed payments. Please contact your owner to resolve this.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.muted)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Contact Owner'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
