import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/payment_provider.dart';
import 'package:my_mkataba/providers/notification_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class RiderPaymentTracker extends ConsumerStatefulWidget {
  const RiderPaymentTracker({super.key});

  @override
  ConsumerState<RiderPaymentTracker> createState() => _RiderPaymentTrackerState();
}

class _RiderPaymentTrackerState extends ConsumerState<RiderPaymentTracker> {
  int _currentIndex = 1;
  final _amountController = TextEditingController();
  bool _showPayForm = false;
  bool _isPaying = false;

  static const _riderId = 'rider-001';
  static const _contractId = 'c1';
  static const _dailyTarget = 4000.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final allPayments = paymentState.payments;
    final riderPayments = allPayments.where((p) => p.riderId == _riderId).toList();
    final paid = riderPayments.where((p) => p.status == PaymentStatus.paid).length;
    final missed = riderPayments.where((p) => p.status == PaymentStatus.missed).length;
    final pending = riderPayments.where((p) => p.status == PaymentStatus.pending).length;
    final totalPaid = riderPayments.where((p) => p.status == PaymentStatus.paid)
        .fold<double>(0, (s, p) => s + p.amountPaid);
    final displayPayments = riderPayments.isNotEmpty ? riderPayments : allPayments;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary, elevation: 0,
        title: const Text('Payments', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showPayForm = !_showPayForm),
            icon: Icon(_showPayForm ? Icons.close : Icons.payments_outlined, color: AppColors.white, size: 18),
            label: Text(_showPayForm ? 'Close' : 'Pay Now',
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenCard(
              child: Column(children: [
                Row(children: [
                  _stat('Paid', '$paid', AppColors.success),
                  _divider(),
                  _stat('Missed', '$missed', AppColors.error),
                  _divider(),
                  _stat('Pending', '$pending', AppColors.accent),
                ]),
                const Divider(height: 16, color: AppColors.border),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total Paid:', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                  Text('TSh ${totalPaid.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success)),
                ]),
              ]),
            ),
            if (_showPayForm) ...[
              const SizedBox(height: 16),
              _payForm(_dailyTarget),
            ],
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const SectionLabel('PAYMENT HISTORY'),
              TextButton.icon(
                onPressed: () => _downloadPdf(totalPaid, displayPayments),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('PDF', style: TextStyle(fontFamily: 'Nunito', fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 8),
            ...displayPayments.reversed.take(20).map((p) => _paymentRow(p)),
          ],
        ),
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

  Widget _payForm(double target) {
    final entered = double.tryParse(_amountController.text) ?? 0;
    final isPartial = entered > 0 && entered < target;
    final isFull = entered >= target;

    return ScreenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Make a Payment', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
          const SizedBox(height: 4),
          Text('Daily target: TSh ${target.toStringAsFixed(0)}',
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              prefixText: 'TSh ',
              hintText: 'Enter amount',
              filled: true, fillColor: AppColors.bg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
          ),
          if (entered > 0 && entered < target) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.accent),
                const SizedBox(width: 6),
                Text('Partial payment — TSh ${(target - entered).toStringAsFixed(0)} remaining',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)),
              ]),
            ),
          ],
          if (entered >= target * 2) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Text('Overpayment — extra TSh ${(entered - target).toStringAsFixed(0)} will be credited',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isPaying || entered <= 0 ? null : () => _submitPayment(entered, isPartial || entered > target),
              icon: _isPaying
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : const Icon(Icons.payments_outlined, size: 18),
              label: Text(
                _isPaying ? 'Processing...'
                    : isPartial ? 'Pay TSh ${entered.toStringAsFixed(0)} (Partial)'
                    : isFull ? 'Pay TSh ${entered.toStringAsFixed(0)}'
                    : 'Enter amount to pay',
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPartial ? AppColors.accent : AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: AppColors.border,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPayment(double amount, bool isPartial) async {
    setState(() => _isPaying = true);
    try {
      ref.read(paymentProvider.notifier).addPayment(Payment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contractId: _contractId,
        riderId: _riderId,
        date: DateTime.now(),
        amountPaid: amount,
        targetAmount: _dailyTarget,
        status: PaymentStatus.paid,
        isPartial: isPartial,
      ));
      if (isPartial) {
        ref.read(notificationProvider.notifier).addNotification(AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _riderId,
          title: 'Partial Payment',
          message: 'You paid TSh ${amount.toStringAsFixed(0)} — TSh ${(_dailyTarget - amount).toStringAsFixed(0)} remaining. Please complete the full amount.',
          timestamp: DateTime.now(),
          type: NotificationType.paymentReminder,
        ));
      }
      _amountController.clear();
      setState(() => _showPayForm = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isPartial
              ? 'TSh ${amount.toStringAsFixed(0)} paid. ${amount > _dailyTarget ? 'Extra credited.' : 'Pay remaining soon!'}'
              : 'Payment of TSh ${amount.toStringAsFixed(0)} successful!'),
          backgroundColor: isPartial ? AppColors.accent : AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      setState(() => _isPaying = false);
    }
  }

  void _downloadPdf(double totalPaid, List<Payment> payments) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Download Payment History'),
        content: const Text('PDF download will be available when backend API is connected.\n\n'
            'For now, payment history is visible in the app.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _paymentRow(Payment p) {
    final color = p.status == PaymentStatus.paid ? AppColors.success
        : p.status == PaymentStatus.missed ? AppColors.error
        : AppColors.accent;
    final label = p.status == PaymentStatus.paid ? 'Paid'
        : p.status == PaymentStatus.missed ? 'Missed'
        : 'Pending';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

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
                Text(
                  p.status == PaymentStatus.paid && p.isPartial
                      ? 'TSh ${p.amountPaid.toStringAsFixed(0)} paid (partial)'
                      : label == 'Paid' ? 'TSh ${p.amountPaid.toStringAsFixed(0)} paid'
                      : label == 'Missed' ? 'Payment missed'
                      : 'Waiting for payment',
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                Text(p.status == PaymentStatus.paid ? 'M-Pesa confirmed' : 'TSh ${p.targetAmount.toStringAsFixed(0)} expected',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
              ]),
            ),
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

  Widget _stat(String label, String value, Color color) {
    return Expanded(child: Column(children: [
      Text(value, style: TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
    ]));
  }

  Widget _divider() => Container(width: 1, height: 32, color: AppColors.border);
}
