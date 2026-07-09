import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/admin_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);
    final stats = admin.stats ?? const SystemStats(
      totalUsers: 156, totalOwners: 12, totalRiders: 143,
      activeContracts: 89, expiredContracts: 23, blockedContracts: 7,
      totalRevenue: 2400000,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.success, elevation: 0,
        title: const Text('Admin Panel', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push( '/admin/notifications')),
              Positioned(right: 8, top: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: _statCard('${stats.totalUsers}', 'Total Users', Icons.people_outline, AppColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: _statCard('${stats.totalOwners}', 'Owners', Icons.person_outline, AppColors.accent)),
              const SizedBox(width: 8),
              Expanded(child: _statCard('${stats.totalRiders}', 'Riders', Icons.pedal_bike_outlined, AppColors.info)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _statCard('${stats.activeContracts}', 'Active', Icons.check_circle_outline, AppColors.success)),
              const SizedBox(width: 8),
              Expanded(child: _statCard('${stats.expiredContracts}', 'Expired', Icons.cancel_outlined, AppColors.error)),
              const SizedBox(width: 8),
              Expanded(child: _statCard('${stats.blockedContracts}', 'Blocked', Icons.block, AppColors.accent)),
            ]),
            const SizedBox(height: 20),
            const SectionLabel('CONTRACTS OVERVIEW'),
            const SizedBox(height: 8),
            ScreenCard(
              child: Column(children: [
                _contractRow('Sarah K.', 'James K.', 'T 123 ABC', 'Active', AppColors.success),
                const Divider(height: 1, color: AppColors.border),
                _contractRow('Sarah K.', 'Peter M.', 'T 456 DEF', 'Active', AppColors.success),
                const Divider(height: 1, color: AppColors.border),
                _contractRow('John M.', 'Ali H.', 'T 789 GHI', 'Blocked', AppColors.error),
                const Divider(height: 1, color: AppColors.border),
                _contractRow('Sarah K.', 'Musa J.', 'T 321 CBA', 'Expired', AppColors.accent),
              ]),
            ),
            const SizedBox(height: 20),
            const SectionLabel('QUICK REPORTS'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _reportCard('Unpaid', '${stats.blockedContracts}', Icons.warning_amber_outlined, AppColors.error)),
              const SizedBox(width: 8),
              Expanded(child: _reportCard('Expired', '${stats.expiredContracts}', Icons.event_busy_outlined, AppColors.accent)),
              const SizedBox(width: 8),
              Expanded(child: _reportCard('Active', '${stats.activeContracts}', Icons.event_available_outlined, AppColors.success)),
            ]),
          ],
        ),
        ),
        ),
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

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return ScreenCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: color),
          const Spacer(),
        ]),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
      ]),
    );
  }

  Widget _contractRow(String owner, String rider, String plate, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(flex: 2, child: Text(owner, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkNavy))),
        Expanded(flex: 2, child: Text(rider, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.darkNavy))),
        Expanded(flex: 2, child: Text(plate, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.muted))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(status, style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
        ),
      ]),
    );
  }

  Widget _reportCard(String label, String count, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => context.push( '/admin/reports'),
      child: ScreenCard(
        child: Column(children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(count, style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
        ]),
      ),
    );
  }
}
