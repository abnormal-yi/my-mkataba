import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final double value;
  final Color color;
  const ProgressBarWidget({super.key, required this.value, this.color = const Color(0xFF6C3FC5)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: value / 100,
        minHeight: 10,
        backgroundColor: const Color(0xFFF3F4F6),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
