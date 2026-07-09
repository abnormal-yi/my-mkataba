import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/rider_summary_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class OwnerIncomeGps extends ConsumerStatefulWidget {
  const OwnerIncomeGps({super.key});

  @override
  ConsumerState<OwnerIncomeGps> createState() => _OwnerIncomeGpsState();
}

class _OwnerIncomeGpsState extends ConsumerState<OwnerIncomeGps> {
  int _currentIndex = 1;
  int _tabIndex = 0;

  List<RiderSummary> get _riders => const [
    RiderSummary(riderId: 'rider-001', riderName: 'James K.', vehiclePlate: 'T 123 ABC',
        contractStatus: ContractStatus.active, daysRemaining: 33, balanceRemaining: 132000),
    RiderSummary(riderId: 'rider-002', riderName: 'Peter M.', vehiclePlate: 'T 456 DEF',
        contractStatus: ContractStatus.active, daysRemaining: 58, balanceRemaining: 88000),
    RiderSummary(riderId: 'rider-003', riderName: 'Ali H.', vehiclePlate: 'T 789 GHI',
        contractStatus: ContractStatus.blocked, daysRemaining: 12, balanceRemaining: 56000, isBlocked: true),
  ];

  @override
  Widget build(BuildContext context) {
    final riderState = ref.watch(riderSummaryProvider);
    final riders = riderState.riders.isNotEmpty ? riderState.riders : _riders;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.accent, elevation: 0,
        title: Text(_tabIndex == 0 ? 'Payments & Income' : 'GPS Trip Tracking',
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          GestureDetector(
            onTap: () => setState(() => _tabIndex = _tabIndex == 0 ? 1 : 0),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_tabIndex == 0 ? Icons.map_outlined : Icons.payments_outlined, size: 16, color: AppColors.white),
                const SizedBox(width: 4),
                Text(_tabIndex == 0 ? 'Trips' : 'Income', style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
      body: _tabIndex == 0 ? _incomeView(riders) : _tripsView(riders),
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

  Widget _incomeView(List<RiderSummary> riders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: StatCard(value: 'TSh 520k', label: 'This Month', valueColor: AppColors.success)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(value: 'TSh 132k', label: 'This Week', valueColor: AppColors.accent)),
          ]),
          const SizedBox(height: 20),
          const SectionLabel('INCOME BY RIDER'),
          const SizedBox(height: 8),
          ...riders.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ScreenCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${r.vehiclePlate} · ${r.riderName}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                  Text('TSh ${_format(r.balanceRemaining)}', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: r.balanceRemaining > 100000 ? AppColors.error : AppColors.success)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1 - (r.balanceRemaining / 500000).clamp(0.0, 1.0),
                    backgroundColor: AppColors.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(r.balanceRemaining > 100000 ? AppColors.error : AppColors.accent),
                    minHeight: 6,
                  ),
                ),
              ]),
            ),
          )),
        ],
      ),
    );
  }

  Widget _tripsView(List<RiderSummary> riders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tripDashboard(),
          const SizedBox(height: 20),
          const SectionLabel('LIVE RIDERS'),
          const SizedBox(height: 8),
          ...riders.map((r) => _riderTripCard(r)),
          const SizedBox(height: 24),
          const SectionLabel('RECENT TRIPS'),
          const SizedBox(height: 8),
          _recentTrips(),
        ],
      ),
    );
  }

  Widget _tripDashboard() {
    return ScreenCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tripStat(Icons.trip_origin, '24', 'Today\'s Trips', AppColors.primary),
          _tripStat(Icons.route_outlined, '68 km', 'Total Distance', AppColors.success),
          _tripStat(Icons.access_time, '6h 12m', 'Active Time', AppColors.accent),
        ],
      ),
    );
  }

  Widget _tripStat(IconData icon, String value, String label, Color color) {
    return Column(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color)),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 9, color: AppColors.muted)),
    ]);
  }

  Widget _riderTripCard(RiderSummary r) {
    final statusColors = {'Active': AppColors.success, 'Idle': AppColors.accent, 'Offline': AppColors.muted};
    final status = r.isBlocked ? 'Offline' : r.riderName == 'James K.' ? 'Active' : 'Idle';
    final color = statusColors[status]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ScreenCard(
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.pedal_bike, size: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(r.riderName, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                const SizedBox(width: 6),
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              ]),
              const SizedBox(height: 2),
              Text('${r.vehiclePlate} · ${r.vehiclePlate.contains('123') ? 'Kariakoo' : r.vehiclePlate.contains('456') ? 'Posta' : 'Mwenge'}',
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.speed, size: 12, color: color),
                const SizedBox(width: 3),
                Text(status == 'Active' ? '32 km/h · 8 trips today' : status == 'Idle' ? 'Stopped · 4 trips today' : 'No trips today',
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 10, color: color)),
              ]),
            ]),
          ),
          GestureDetector(
            onTap: () => _showTripDetail(r),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(status, style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _recentTrips() {
    final trips = [
      {'rider': 'James K.', 'plate': 'T 123 ABC', 'from': 'Kariakoo', 'to': 'Posta', 'fare': 'TSh 3,500', 'time': '10 min', 'dist': '4.2 km', 'status': 'Completed'},
      {'rider': 'Peter M.', 'plate': 'T 456 DEF', 'from': 'Mwenge', 'to': 'Kawe', 'fare': 'TSh 5,000', 'time': '18 min', 'dist': '7.8 km', 'status': 'Completed'},
      {'rider': 'James K.', 'plate': 'T 123 ABC', 'from': 'Posta', 'to': 'Kariakoo', 'fare': 'TSh 3,000', 'time': '8 min', 'dist': '3.5 km', 'status': 'Completed'},
    ];

    return Column(
      children: trips.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ScreenCard(
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.route, size: 20, color: AppColors.success)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${t['rider']} · ${t['plate']}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                const SizedBox(height: 2),
                Text('${t['from']} → ${t['to']}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.timer_outlined, size: 10, color: AppColors.muted),
                  const SizedBox(width: 2),
                  Text(t['time']!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
                  const SizedBox(width: 8),
                  Icon(Icons.straighten, size: 10, color: AppColors.muted),
                  const SizedBox(width: 2),
                  Text(t['dist']!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
                  const SizedBox(width: 8),
                  Icon(Icons.monetization_on_outlined, size: 10, color: AppColors.muted),
                  const SizedBox(width: 2),
                  Text(t['fare']!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
                ]),
              ]),
            ),
          ]),
        ),
      )).toList(),
    );
  }

  void _showTripDetail(RiderSummary r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(r.riderName, style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
            const SizedBox(height: 4),
            Text(r.vehiclePlate, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.muted)),
            const SizedBox(height: 16),
            Row(children: [
              _detailTile(Icons.speed, 'Avg Speed', '28 km/h'),
              _detailTile(Icons.route_outlined, 'Today', '8 trips · 22 km'),
              _detailTile(Icons.access_time, 'Online', '5h 20m'),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.near_me, size: 18),
                label: const Text('Track Live Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Expanded(child: Column(children: [
      Icon(icon, size: 20, color: AppColors.accent),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
      Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
    ]));
  }

  String _format(double n) => '${n.round().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}
