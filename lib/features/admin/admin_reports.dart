import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/providers/admin_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class AdminReports extends ConsumerStatefulWidget {
  const AdminReports({super.key});

  @override
  ConsumerState<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends ConsumerState<AdminReports> {
  int _currentIndex = 2;

  final _reportNames = ['Unpaid Contracts', 'Expired Contracts', 'Active Contracts', 'All Contracts'];

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);
    final selectedReport = admin.selectedReport;
    final reports = admin.reports.isNotEmpty ? admin.reports : <String, List<Map<String, String>>>{};
    final data = reports[selectedReport] ?? [];

    final paidCount = admin.stats?.activeContracts ?? 0;
    final unpaidCount = admin.stats?.blockedContracts ?? 0;
    final totalRevenue = admin.stats?.totalRevenue ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.success, elevation: 0,
        title: const Text('Reports', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _reportNames.map((r) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => ref.read(adminProvider.notifier).setSelectedReport(r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedReport == r ? AppColors.success : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: selectedReport == r ? AppColors.success : AppColors.border),
                      ),
                      child: Text(r, style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600,
                          color: selectedReport == r ? AppColors.white : AppColors.muted)),
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _summaryCard('Paid', '$paidCount', AppColors.success, Icons.check_circle_outline)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('Unpaid', '$unpaidCount', AppColors.error, Icons.warning_amber_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('Revenue', 'TSh ${(totalRevenue / 1000).toStringAsFixed(0)}k', AppColors.primary, Icons.payments_outlined)),
            ]),
            const SizedBox(height: 16),
            ScreenCard(
              child: Column(children: [
                Row(children: [
                  _header('Owner', 2),
                  _header('Rider', 2),
                  _header('Plate', 2),
                  _header('Balance', 2),
                  _header('Days', 1),
                ]),
                const Divider(color: AppColors.border),
                ...data.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    _cell(row['owner']!, 2, true),
                    _cell(row['rider']!, 2, false),
                    _cell(row['plate']!, 2, false),
                    _cell(row['balance']!, 2, false),
                    _cell(row['days']!, 1, false),
                  ]),
                )),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex, activeColor: AppColors.success,
        items: const [
          NavItemData(icon: Icons.dashboard_outlined, label: 'Dashboard'),
          NavItemData(icon: Icons.people_outline, label: 'Users'),
          NavItemData(icon: Icons.file_present_outlined, label: 'Reports'),
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

  Widget _summaryCard(String label, String value, Color color, IconData icon) {
    return ScreenCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const Spacer(),
        ]),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
      ]),
    );
  }

  Widget _header(String text, int flex) {
    return Expanded(flex: flex, child: Text(text, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted)));
  }

  Widget _cell(String text, int flex, bool bold) {
    return Expanded(flex: flex, child: Text(text, style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: AppColors.darkNavy)));
  }
}
