import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/payment_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class OwnerRiderDetail extends ConsumerStatefulWidget {
  final String riderId;
  final String riderName;
  final String vehiclePlate;
  final double balanceRemaining;
  final bool isBlocked;

  const OwnerRiderDetail({
    super.key, required this.riderId, required this.riderName,
    required this.vehiclePlate, this.balanceRemaining = 0,
    this.isBlocked = false,
  });

  @override
  ConsumerState<OwnerRiderDetail> createState() => _OwnerRiderDetailState();
}

class _OwnerRiderDetailState extends ConsumerState<OwnerRiderDetail> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final riderPayments = paymentState.payments
        .where((p) => p.riderId == widget.riderId).toList();
    final payments = riderPayments.isNotEmpty ? riderPayments : List.generate(20, (i) {
      final day = DateTime.now().subtract(Duration(days: 19 - i));
      final status = i > 15 ? PaymentStatus.pending : i == 3 || i == 7 ? PaymentStatus.missed : PaymentStatus.paid;
      return Payment(
        id: 'or-$i', contractId: 'c1', riderId: widget.riderId, date: day,
        amountPaid: status == PaymentStatus.paid ? 4000 : 0,
        targetAmount: 4000, status: status,
      );
    });

    final paidPayments = payments.where((p) => p.status == PaymentStatus.paid).toList();
    final totalPaid = paidPayments.fold<double>(0, (sum, p) => sum + p.amountPaid);
    final missedCount = payments.where((p) => p.status == PaymentStatus.missed).length;
    final daysRemaining = 33;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.accent, elevation: 0,
        title: Text(widget.riderName, style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          if (widget.isBlocked)
            TextButton.icon(
              onPressed: () => _unblockRider(),
              icon: const Icon(Icons.lock_open_outlined, size: 16, color: AppColors.white),
              label: const Text('Unblock', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenCard(
              child: Row(children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                  child: Text(widget.riderName.split(' ').map((s) => s.isNotEmpty ? s[0] : '').join(),
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.riderName, style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                    Text(widget.vehiclePlate, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.muted)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (widget.isBlocked ? AppColors.error : AppColors.success).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.isBlocked ? 'Blocked' : 'Active',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700,
                          color: widget.isBlocked ? AppColors.error : AppColors.success)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _detailCard('Daily Target', 'TSh 4,000', Icons.payments_outlined, AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: _detailCard('Total Paid', 'TSh ${totalPaid.toStringAsFixed(0)}', Icons.account_balance_wallet_outlined, AppColors.success)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _detailCard('Days Left', '$daysRemaining', Icons.calendar_today_outlined, AppColors.accent)),
              const SizedBox(width: 10),
              Expanded(child: _detailCard('Missed', '$missedCount', Icons.cancel_outlined, AppColors.error)),
            ]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionLabel('PAYMENT HISTORY'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Total: TSh ${totalPaid.toStringAsFixed(0)}',
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...payments.reversed.take(15).map((p) => _paymentRow(p, payments)),
          ],
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

  void _unblockRider() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Unblock Rider'),
        content: Text('Unblock ${widget.riderName}? They will regain access to the system.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${widget.riderName} has been unblocked'),
                backgroundColor: AppColors.success,
              ));
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(Payment p, List<Payment> allPayments) {
    final color = p.status == PaymentStatus.paid ? AppColors.success
        : p.status == PaymentStatus.missed ? AppColors.error
        : AppColors.accent;
    final label = p.status == PaymentStatus.paid ? 'Paid'
        : p.status == PaymentStatus.missed ? 'Missed'
        : 'Pending';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final paidSoFar = allPayments
        .where((x) => x.status == PaymentStatus.paid && !x.date.isAfter(p.date))
        .fold<double>(0, (sum, x) => sum + x.amountPaid);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ScreenCard(
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${p.date.day}', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: color)),
                Text(months[p.date.month - 1], style: TextStyle(fontFamily: 'Nunito', fontSize: 8, fontWeight: FontWeight.w600, color: color)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TSh ${p.amountPaid.toStringAsFixed(0)} paid',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                Text(p.status == PaymentStatus.paid ? 'M-Pesa confirmed' : 'TSh ${p.targetAmount.toStringAsFixed(0)} expected',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('TSh ${paidSoFar.toStringAsFixed(0)}',
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(String label, String value, IconData icon, Color color) {
    return ScreenCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const Spacer(),
        ]),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
      ]),
    );
  }
}
