import 'package:flutter/material.dart';

class ToastWidget extends StatelessWidget {
  final String message;
  const ToastWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100, left: 24, right: 24,
      child: Material(
        elevation: 8, borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1F2937),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
