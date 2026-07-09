import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/notification_provider.dart';

class RiderNotifications extends ConsumerStatefulWidget {
  const RiderNotifications({super.key});

  @override
  ConsumerState<RiderNotifications> createState() => _RiderNotificationsState();
}

class _RiderNotificationsState extends ConsumerState<RiderNotifications> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final notifications = notifState.notifications.isNotEmpty ? notifState.notifications : <AppNotification>[];
    final unread = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary, elevation: 0,
        title: Text('Notifications ($unread)', style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (_, i) {
          final n = notifications[i];
          final icon = n.type == NotificationType.paymentReminder ? Icons.payment
              : n.type == NotificationType.missedPayment ? Icons.warning_amber_outlined
              : n.type == NotificationType.contractExpiry ? Icons.event
              : Icons.notifications_outlined;
          final color = n.type == NotificationType.missedPayment ? AppColors.error
              : n.type == NotificationType.contractExpiry ? AppColors.accent
              : AppColors.primary;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ScreenCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, size: 20, color: color)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(n.title, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800, color: AppColors.darkNavy))),
                        if (!n.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      ]),
                      const SizedBox(height: 2),
                      Text(n.message, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
                      const SizedBox(height: 4),
                      Text(_timeAgo(n.timestamp), style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex, activeColor: AppColors.primary,
        items: const [
          NavItemData(icon: Icons.dashboard_outlined, label: 'Dashboard'),
          NavItemData(icon: Icons.payments_outlined, label: 'Payments'),
          NavItemData(icon: Icons.description_outlined, label: 'Contracts'),
          NavItemData(icon: Icons.notifications_outlined, label: 'Alerts'),
          NavItemData(icon: Icons.person_outline, label: 'Profile'),
        ],
        onTap: (i) {
          setState(() => _currentIndex = i);
          final routes = ['/rider/dashboard', '/rider/payments', '/rider/contracts', '/rider/notifications', '/rider/profile'];
          if (i < routes.length) context.go( routes[i]);
        },
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}
