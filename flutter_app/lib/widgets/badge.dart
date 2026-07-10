import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String status;
  final String? label;
  const BadgeWidget({super.key, required this.status, this.label});

  Color _bg() {
    switch (status.toLowerCase()) {
      case 'active': case 'paid': case 'completed': return const Color(0xFFD1FAE5);
      case 'pending': return const Color(0xFFFEF3C7);
      case 'overdue': case 'missed': case 'blocked': case 'rejected': return const Color(0xFFFEE2E2);
      case 'partial': return const Color(0xFFFFF3E0);
      case 'accepted': case 'purple': return const Color(0xFFEDE9FE);
      default: return const Color(0xFFF3F4F6);
    }
  }

  Color _fg() {
    switch (status.toLowerCase()) {
      case 'active': case 'paid': case 'completed': return const Color(0xFF059669);
      case 'pending': return const Color(0xFFD97706);
      case 'overdue': case 'missed': case 'blocked': case 'rejected': return const Color(0xFFDC2626);
      case 'partial': return const Color(0xFFEA580C);
      case 'accepted': case 'purple': return const Color(0xFF6C3FC5);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _bg(), borderRadius: BorderRadius.circular(20)),
      child: Text(label ?? status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _fg())),
    );
  }
}
