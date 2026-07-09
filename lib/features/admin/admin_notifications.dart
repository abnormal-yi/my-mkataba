import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/notification_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class AdminNotifications extends ConsumerStatefulWidget {
  const AdminNotifications({super.key});

  @override
  ConsumerState<AdminNotifications> createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends ConsumerState<AdminNotifications> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final items = notifState.notifications.isNotEmpty
        ? notifState.notifications.map((n) => _notifToItem(n)).toList()
        : [
            {'title': 'New User Registered', 'msg': 'Peter M. joined as Rider', 'color': AppColors.primary, 'icon': Icons.person_add_outlined},
            {'title': 'Missed Payment Alert', 'msg': 'Ali H. missed 5 payments — auto-blocked', 'color': AppColors.error, 'icon': Icons.warning_amber_outlined},
            {'title': 'Contract Expired', 'msg': 'Musa J. contract expired yesterday', 'color': AppColors.accent, 'icon': Icons.event_busy_outlined},
            {'title': 'New Contract Created', 'msg': 'Sarah K. created contract with Peter M.', 'color': AppColors.success, 'icon': Icons.description_outlined},
            {'title': 'Payment Received', 'msg': 'TSh 120,000 collected this week', 'color': AppColors.info, 'icon': Icons.trending_up_outlined},
          ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.success, elevation: 0,
        title: const Text('System Alerts', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ScreenCard(
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: (item['color'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(item['icon'] as IconData, size: 20, color: item['color'] as Color)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['title'] as String, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                  Text(item['msg'] as String, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
                ])),
              ]),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex, activeColor: AppColors.success,
        items: const [
          NavItemData(icon: Icons.dashboard_outlined, label: 'Dashboard'),
          NavItemData(icon: Icons.people_outline, label: 'Users'),
          NavItemData(icon: Icons.assessment_outlined, label: 'Reports'),
          NavItemData(icon: Icons.notifications_outlined, label: 'Alerts'),
          NavItemData(icon: Icons.settings_outlined, label: 'Settings'),
        ],
        onTap: (i) {
          setState(() => _currentIndex = i);
          final routes = ['/admin/dashboard', '/admin/users', '/admin/reports', '/admin/notifications'];
          if (i < routes.length) context.go( routes[i]);
        },
      ),
    );
  }

  Map<String, dynamic> _notifToItem(AppNotification n) {
    final color = n.type == NotificationType.missedPayment ? AppColors.error
        : n.type == NotificationType.contractExpiry ? AppColors.accent
        : n.type == NotificationType.paymentReminder ? AppColors.info
        : n.type == NotificationType.contractCreated ? AppColors.success
        : AppColors.primary;
    final icon = n.type == NotificationType.missedPayment ? Icons.warning_amber_outlined
        : n.type == NotificationType.contractExpiry ? Icons.event_busy_outlined
        : n.type == NotificationType.paymentReminder ? Icons.payment
        : n.type == NotificationType.contractCreated ? Icons.description_outlined
        : Icons.notifications_outlined;
    return {'title': n.title, 'msg': n.message, 'color': color, 'icon': icon};
  }
}
