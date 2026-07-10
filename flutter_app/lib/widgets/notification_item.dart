import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel item;
  const NotificationItemWidget({super.key, required this.item});

  IconData _icon() {
    switch (item.type) {
      case 'paid': return Icons.check_circle;
      case 'missed': case 'danger': return Icons.cancel;
      case 'warning': return Icons.warning_amber;
      case 'reminder': return Icons.notifications;
      case 'expiry': return Icons.schedule;
      default: return Icons.circle;
    }
  }

  Color _color() {
    switch (item.type) {
      case 'paid': return const Color(0xFF059669);
      case 'danger': case 'missed': return const Color(0xFFDC2626);
      case 'warning': return const Color(0xFFD97706);
      case 'reminder': return const Color(0xFF6C3FC5);
      case 'expiry': return const Color(0xFFEC4899);
      default: return const Color(0xFF9CA3AF);
    }
  }

  Color _bg() {
    switch (item.type) {
      case 'paid': return const Color(0xFFD1FAE5);
      case 'danger': case 'missed': return const Color(0xFFFEE2E2);
      case 'warning': return const Color(0xFFFEF3C7);
      case 'reminder': return const Color(0xFFEDE9FE);
      case 'expiry': return const Color(0xFFFDF2F8);
      default: return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: _bg(), borderRadius: BorderRadius.circular(10)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(_icon(), color: _color(), size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          Text(item.desc, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
          const SizedBox(height: 4),
          Text(item.time, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
        ])),
      ]),
    );
  }
}
