import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/auth_provider.dart';
import 'package:my_mkataba/providers/contract_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class RiderDashboard extends ConsumerStatefulWidget {
  const RiderDashboard({super.key});

  @override
  ConsumerState<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends ConsumerState<RiderDashboard> {
  int _currentIndex = 0;

  final _fallbackContract = Contract(
    id: 'ct-001', ownerId: 'own-001', ownerName: 'Sarah K.',
    riderId: 'rider-001', riderName: 'James K.',
    vehiclePlate: 'T 123 ABC', vehicleType: 'Bajaj',
    startDate: DateTime(2026, 1, 15), endDate: DateTime(2026, 7, 15),
    paymentType: PaymentType.daily, totalAmount: 720000, dailyTarget: 4000,
    status: ContractStatus.active, agreementAccepted: true,
    agreementDate: DateTime(2026, 1, 15), missedPayments: 2,
  );

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final contractState = ref.watch(contractProvider);
    final contract = contractState.contracts.isNotEmpty ? contractState.contracts.first : _fallbackContract;
    final isBlocked = contract.status == ContractStatus.blocked;

    if (isBlocked) return _blockedScreen();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(auth.user?.name != null ? 'Hi, ${auth.user!.name.split(' ').first}' : 'My Dashboard',
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push( '/rider/notifications')),
              Positioned(right: 8, top: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))),
            ],
          ),
        ],
      ),
      body: contractState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _contractStatusCard(contract),
                      const SizedBox(height: 12),
                      _paymentOverview(contract),
                      const SizedBox(height: 12),
                      _dailyTracker(contract),
                      const SizedBox(height: 12),
                      _notificationsPanel(),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _contractStatusCard(Contract c) {
    final statusColor = c.status == ContractStatus.active ? AppColors.success
        : c.status == ContractStatus.expired ? AppColors.error
        : AppColors.accent;
    final statusLabel = c.status == ContractStatus.active ? 'Active'
        : c.status == ContractStatus.expired ? 'Expired'
        : 'Pending';

    return ScreenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(c.vehiclePlate, style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(statusLabel, style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${c.vehicleType} · Owner: ${c.ownerName}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(Icons.calendar_today, '${c.daysRemaining} days left', AppColors.info),
              const SizedBox(width: 8),
              _infoChip(Icons.repeat, c.paymentType.name.toUpperCase(), AppColors.accent),
              const SizedBox(width: 8),
              _infoChip(Icons.person, c.ownerName, AppColors.primaryLight, textColor: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentOverview(Contract c) {
    final paid = c.totalAmount - (c.missedPayments * c.dailyTarget);
    final progress = (paid / c.totalAmount).clamp(0.0, 1.0);
    return ScreenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text('Payment Overview', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _amountCol('Total', 'TSh ${_format(c.totalAmount)}', AppColors.darkNavy),
              _amountCol('Paid', 'TSh ${_format(paid)}', AppColors.success),
              _amountCol('Remaining', 'TSh ${_format(c.totalAmount - paid)}', AppColors.error),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(progress > 0.5 ? AppColors.success : AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text('${(progress * 100).toStringAsFixed(0)}% completed', style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _dailyTracker(Contract c) {
    final days = List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      final status = i == 6 ? PaymentStatus.paid : i == 4 ? PaymentStatus.missed : PaymentStatus.paid;
      return _dayTile(day, status);
    });

    return ScreenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('This Week', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                ],
              ),
              Text('${c.missedPayments} missed', style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: days),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(Colors.green, 'Paid'),
              const SizedBox(width: 16),
              _legend(AppColors.accent, 'Pending'),
              const SizedBox(width: 16),
              _legend(AppColors.error, 'Missed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayTile(DateTime date, PaymentStatus status) {
    final colors = {
      PaymentStatus.paid: AppColors.success,
      PaymentStatus.missed: AppColors.error,
      PaymentStatus.pending: AppColors.accent,
      PaymentStatus.unpaid: AppColors.lightGray,
    };
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayIndex = date.weekday - 1;
    final c = colors[status]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(labels[dayIndex], style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
        const SizedBox(height: 4),
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: c.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text('${date.day}', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: c))),
        ),
      ],
    );
  }

  Widget _notificationsPanel() {
    return ScreenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text('Notifications', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
            ],
          ),
          const SizedBox(height: 12),
          _notifItem(Icons.payment, 'Payment reminder due today', 'TSh 4,000 due today', AppColors.accent),
          const Divider(height: 1, color: AppColors.border),
          _notifItem(Icons.warning_amber_outlined, 'Missed payment alert', 'You missed 2 payments this week', AppColors.error),
          const Divider(height: 1, color: AppColors.border),
          _notifItem(Icons.event, 'Contract expires soon', '14 days remaining', AppColors.info),
        ],
      ),
    );
  }

  Widget _notifItem(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
            Text(subtitle, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
          ])),
        ],
      ),
    );
  }

  Widget _blockedScreen() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.block, size: 40, color: AppColors.error)),
              const SizedBox(height: 24),
              const Text('Account Blocked', style: TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
              const SizedBox(height: 8),
              const Text('Your contract has been blocked due to missed payments. Please contact your owner to resolve this.',
                textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: AppColors.muted)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                  child: const Text('Contact Owner'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavBar(
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
    );
  }

  Widget _infoChip(IconData icon, String text, Color bg, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: textColor ?? bg),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w600, color: textColor ?? bg)),
      ]),
    );
  }

  Widget _amountCol(String label, String amount, Color color) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
      const SizedBox(height: 2),
      Text(amount, style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: color)),
    ]));
  }

  Widget _legend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
    ]);
  }

  String _format(double n) => '${n.round().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}
