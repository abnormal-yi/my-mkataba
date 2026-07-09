import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/notification_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class OwnerNotifications extends ConsumerStatefulWidget {
  const OwnerNotifications({super.key});

  @override
  ConsumerState<OwnerNotifications> createState() => _OwnerNotificationsState();
}

class _OwnerNotificationsState extends ConsumerState<OwnerNotifications> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final items = notifState.notifications.isNotEmpty
        ? notifState.notifications.map((n) => _notifToItem(n)).toList()
        : [
            {'title': 'Missed Payment', 'msg': 'James K. missed payment on Jun 10 (TSh 4,000)', 'color': AppColors.error, 'icon': Icons.warning_amber_outlined},
            {'title': 'Contract Expiring', 'msg': 'Ali H. contract ends in 12 days', 'color': AppColors.accent, 'icon': Icons.event},
            {'title': 'Payment Received', 'msg': 'Peter M. paid TSh 4,000 via M-Pesa', 'color': AppColors.success, 'icon': Icons.payment},
            {'title': 'Account Blocked', 'msg': 'Ali H. blocked — 5 payments missed', 'color': AppColors.error, 'icon': Icons.block},
            {'title': 'Contract Created', 'msg': 'New contract with Peter M. started', 'color': AppColors.primary, 'icon': Icons.description_outlined},
          ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.accent, elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
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
        currentIndex: _currentIndex, activeColor: AppColors.accent,
        items: const [
          NavItemData(icon: Icons.dashboard_outlined, label: 'Dashboard'),
          NavItemData(icon: Icons.payments_outlined, label: 'Payments'),
          NavItemData(icon: Icons.description_outlined, label: 'Contracts'),
          NavItemData(icon: Icons.notifications_outlined, label: 'Alerts'),
          NavItemData(icon: Icons.person_outline, label: 'Profile'),
        ],
        onTap: (i) {
          setState(() => _currentIndex = i);
          final routes = ['/owner/dashboard', '/owner/income', '/owner/create-contract', '/owner/notifications'];
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
        : n.type == NotificationType.accountBlocked ? AppColors.error
        : AppColors.primary;
    final icon = n.type == NotificationType.missedPayment ? Icons.warning_amber_outlined
        : n.type == NotificationType.contractExpiry ? Icons.event
        : n.type == NotificationType.paymentReminder ? Icons.payment
        : n.type == NotificationType.contractCreated ? Icons.description_outlined
        : n.type == NotificationType.accountBlocked ? Icons.block
        : Icons.notifications_outlined;
    return {'title': n.title, 'msg': n.message, 'color': color, 'icon': icon};
  }
}
