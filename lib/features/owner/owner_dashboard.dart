import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/rider_summary_provider.dart';
import 'package:my_mkataba/providers/payment_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class OwnerDashboard extends ConsumerStatefulWidget {
  const OwnerDashboard({super.key});

  @override
  ConsumerState<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends ConsumerState<OwnerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final riderState = ref.watch(riderSummaryProvider);
    final _riders = riderState.riders.isNotEmpty ? riderState.riders : const [
      RiderSummary(riderId: 'rider-001', riderName: 'James K.', vehiclePlate: 'T 123 ABC',
          contractStatus: ContractStatus.active, daysRemaining: 33, balanceRemaining: 132000, missedPayments: 2),
      RiderSummary(riderId: 'rider-002', riderName: 'Peter M.', vehiclePlate: 'T 456 DEF',
          contractStatus: ContractStatus.active, daysRemaining: 58, balanceRemaining: 88000, missedPayments: 0),
      RiderSummary(riderId: 'rider-003', riderName: 'Ali H.', vehiclePlate: 'T 789 GHI',
          contractStatus: ContractStatus.blocked, daysRemaining: 12, balanceRemaining: 56000, missedPayments: 5, isBlocked: true),
    ];
    final paymentState = ref.watch(paymentProvider);
    final allPaid = paymentState.payments.where((p) => p.status == PaymentStatus.paid)
        .fold<double>(0, (s, p) => s + p.amountPaid);
    final activeRiders = _riders.where((r) => r.contractStatus == ContractStatus.active).length;
    final totalRevenue = _riders.fold<double>(0, (sum, r) => sum + r.balanceRemaining);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.accent, elevation: 0,
        title: const Text('Owner Dashboard', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.person_add_outlined), onPressed: () => _showRegisterRiderDialog()),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => context.push( '/owner/create-contract')),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push( '/owner/notifications')),
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
              Expanded(child: _summaryCard('${_riders.length}', 'Total Riders', Icons.people_outline, AppColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('$activeRiders', 'Active', Icons.check_circle_outline, AppColors.success)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _summaryCard('TSh ${_format(allPaid)}', 'Collected', Icons.account_balance_wallet_outlined, AppColors.success)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('TSh ${_format(totalRevenue)}', 'Outstanding', Icons.account_balance_wallet_outlined, AppColors.primary)),
            ]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionLabel('YOUR RIDERS'),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._riders.map((r) => _riderCard(r)),
            const SizedBox(height: 16),
            _alertsPanel(),
          ],
        ),
        ),
        ),
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

  Widget _summaryCard(String value, String label, IconData icon, Color color) {
    return ScreenCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: color),
          const Spacer(),
        ]),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }

  Widget _riderCard(RiderSummary r) {
    final statusColor = r.contractStatus == ContractStatus.active
        ? AppColors.success : r.contractStatus == ContractStatus.blocked
        ? AppColors.error : AppColors.accent;
    final statusLabel = r.contractStatus == ContractStatus.active ? 'Active'
        : r.contractStatus == ContractStatus.blocked ? 'Blocked' : 'Expired';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => context.push('/owner/rider-detail/${r.riderId}/${Uri.encodeComponent(r.riderName)}/${Uri.encodeComponent(r.vehiclePlate)}/${r.balanceRemaining.round()}/${r.isBlocked ? 1 : 0}'),
        child: ScreenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(radius: 18, backgroundColor: AppColors.accentLight,
                  child: Text(r.riderName.split(' ').map((s) => s[0]).join(),
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.accent))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.riderName, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                  Text('${r.vehiclePlate} · ${r.daysRemaining} days left', style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(statusLabel, style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _riderStat('Balance', 'TSh ${_format(r.balanceRemaining)}', AppColors.error),
                const SizedBox(width: 16),
                _riderStat('Missed', '${r.missedPayments} days', r.missedPayments > 0 ? AppColors.error : AppColors.success),
                const SizedBox(width: 16),
                _riderStat('Status', r.isBlocked ? 'Blocked' : 'OK', r.isBlocked ? AppColors.error : AppColors.success),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _riderStat(String label, String value, Color color) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
      Text(value, style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]));
  }

  Widget _alertsPanel() {
    return ScreenCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.notifications_active_outlined, size: 16, color: AppColors.accent),
          SizedBox(width: 6),
          Text('Alerts', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
        ]),
        const SizedBox(height: 8),
        _alertItem('James K. missed 2 payments', AppColors.error),
        _alertItem('Ali H. contract expiring in 12 days', AppColors.accent),
        _alertItem('Ali H. account blocked — action needed', AppColors.error),
        _alertItem('Peter M. on track — 0 missed payments', AppColors.success),
      ]),
    );
  }

  Widget _alertItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.darkNavy))),
      ]),
    );
  }

  String _format(double n) => '${n.round().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  void _showRegisterRiderDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register New Rider'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', filled: true, fillColor: AppColors.bg, border: OutlineInputBorder()), style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.darkNavy)),
            const SizedBox(height: 8),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: AppColors.bg, border: OutlineInputBorder()), style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.darkNavy)),
            const SizedBox(height: 8),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone (+255)', filled: true, fillColor: AppColors.bg, border: OutlineInputBorder()), style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.darkNavy)),
            const SizedBox(height: 8),
            TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: 'Vehicle Plate', filled: true, fillColor: AppColors.bg, border: OutlineInputBorder()), style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.darkNavy)),
            const SizedBox(height: 8),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: AppColors.bg, border: OutlineInputBorder()), style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.darkNavy)),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Rider ${nameCtrl.text} registered. They can now login.'),
                backgroundColor: AppColors.success,
              ));
            },
            child: const Text('Register Rider'),
          ),
        ],
      ),
    );
  }
}
