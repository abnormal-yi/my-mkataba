import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final dynamic value;
  final String? note;
  final Color color;
  const StatCard({super.key, required this.label, required this.value, this.note, this.color = const Color(0xFF6C3FC5)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 6),
        DefaultTextStyle(
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
          child: value is Widget ? value : Text('$value'),
        ),
        if (note != null) ...[const SizedBox(height: 4), Text(note!, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)))],
      ]),
    );
  }
}
