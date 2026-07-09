import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/contract_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class RiderContracts extends ConsumerStatefulWidget {
  const RiderContracts({super.key});

  @override
  ConsumerState<RiderContracts> createState() => _RiderContractsState();
}

class _RiderContractsState extends ConsumerState<RiderContracts> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final contractState = ref.watch(contractProvider);
    final contracts = contractState.contracts.isNotEmpty
        ? contractState.contracts
        : [Contract(id: 'ct-001', ownerId: 'own-001', ownerName: 'Sarah K.', riderId: 'rider-001', riderName: 'James K.',
            vehiclePlate: 'T 123 ABC', vehicleType: 'Bajaj',
            startDate: DateTime(2026, 1, 15), endDate: DateTime(2026, 7, 15),
            paymentType: PaymentType.daily, totalAmount: 720000, dailyTarget: 4000,
            status: ContractStatus.active, agreementAccepted: true, agreementDate: DateTime(2026, 1, 15), missedPayments: 2)];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary, elevation: 0,
        title: const Text('My Contracts', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: contractState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : contracts.isEmpty
              ? const Center(child: Text('No contracts', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: AppColors.muted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contracts.length,
                  itemBuilder: (_, i) => _contractCard(contracts[i]),
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

  Widget _contractCard(Contract c) {
    final progress = c.daysElapsed / c.totalDays;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScreenCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.motorcycle_outlined, color: AppColors.primary, size: 22)),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.vehiclePlate, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
                    Text(c.vehicleType, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
                  ]),
                ]),
                StatusBadge.green(c.status == ContractStatus.active ? 'Active' : c.status.name),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              _info('Owner', c.ownerName),
              _info('Type', c.paymentType.name.toUpperCase()),
              _info('Target', 'TSh ${c.dailyTarget.toStringAsFixed(0)}/day'),
            ]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${c.daysElapsed}/${c.totalDays} days', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
                Text('${c.daysRemaining} days left', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, color: c.daysRemaining < 30 ? AppColors.error : AppColors.muted)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.lightGray,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            if (c.agreementAccepted) ...[
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text('Agreement accepted', style: TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.success)),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
      Text(value, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkNavy)),
    ]));
  }
}
