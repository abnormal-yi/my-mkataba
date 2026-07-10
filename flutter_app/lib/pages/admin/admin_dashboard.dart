import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/user_model.dart';
import '../../models/contract_model.dart';
import '../../models/payment_model.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/badge.dart';
import '../../widgets/data_table.dart';
import '../../widgets/toast.dart';
import '../login_page.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel user;
  const AdminDashboard({super.key, required this.user});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late UserModel _user;
  int _tab = 0;
  List<UserModel> _users = [];
  List<ContractModel> _contracts = [];
  List<PaymentModel> _payments = [];
  String _toastMsg = '';

  final List<_TabConfig> _tabs = const [
    _TabConfig(Icons.dashboard, 'Overview'),
    _TabConfig(Icons.people, 'Users'),
    _TabConfig(Icons.description, 'Contracts'),
    _TabConfig(Icons.payment, 'Payments'),
    _TabConfig(Icons.analytics, 'Reports'),
    _TabConfig(Icons.person, 'Profile'),
  ];

  @override
  void initState() { _user = widget.user; _loadData(); super.initState(); }

  void _loadData() {
    _users = DbHelper.getAllUsers();
    _contracts = DbHelper.getAllContracts();
    _payments = DbHelper.getAllPayments();
    setState(() {});
  }

  void _toast(String msg) { setState(() => _toastMsg = msg); Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _toastMsg = ''); }); }

  void _deleteRider(UserModel rider) {
    DbHelper.deleteRider(rider.id);
    _loadData();
  }

  void _showPaymentHistory(UserModel rider) {
    final payments = _payments.where((p) => _contracts.any((c) => c.contractId == p.contractId && c.riderId == rider.id)).toList();
    showModalBottomSheet(context: context, builder: (_) => SizedBox(
      height: MediaQuery.of(context).size.height * .6,
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${rider.name} – Payment History', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 12),
        Expanded(child: payments.isEmpty
          ? const Center(child: Text('No payments.', style: TextStyle(color: Color(0xFF9CA3AF))))
          : ListView.builder(itemCount: payments.length, itemBuilder: (_, i) => ListTile(
              dense: true,
              title: Text('TSh ${_fmt(payments[i].amount)}'),
              subtitle: Text('${payments[i].date} via ${payments[i].method}'),
              trailing: BadgeWidget(status: payments[i].status),
            ))),
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'Good ${DateTime.now().hour < 12 ? 'morning' : 'afternoon'}, ${_user.name.split(' ')[0]} 👋' : _tabs[_tab].label),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())))],
      ),
      body: Stack(children: [_buildTabContent(), if (_toastMsg.isNotEmpty) ToastWidget(message: _toastMsg)]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: _tabs.map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label)).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case 0: return _buildOverview();
      case 1: return _buildUsersTab();
      case 2: return _buildContractsTab();
      case 3: return _buildPaymentsTab();
      case 4: return _buildReportsTab();
      case 5: return _buildProfileTab();
      default: return const SizedBox();
    }
  }

  Widget _buildOverview() {
    final riders = _users.where((u) => u.role == 'rider').length;
    final owners = _users.where((u) => u.role == 'owner').length;
    final active = _contracts.where((c) => c.status == 'Accepted' || c.status == 'Confirmed' || c.status == 'Active').length;
    final totalPaid = _payments.where((p) => p.status == 'paid' || p.status == 'Paid').fold<int>(0, (s, p) => s + p.amount);
    final pending = _payments.where((p) => p.status == 'pending' || p.status == 'Pending').fold<int>(0, (s, p) => s + p.amount);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('System-wide overview of all activity', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
      const SizedBox(height: 16),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.6, mainAxisSpacing: 10, crossAxisSpacing: 10, children: [
        StatCard(label: 'Total Users', value: _users.length, note: '$riders riders, $owners owners', color: const Color(0xFF6C3FC5)),
        StatCard(label: 'Active Contracts', value: active, note: 'out of ${_contracts.length} total'),
        StatCard(label: 'Revenue Collected', value: 'TSh ${_fmt(totalPaid)}', note: 'from all users', color: const Color(0xFF059669)),
        StatCard(label: 'Outstanding', value: 'TSh ${_fmt(pending)}', note: 'pending payments', color: const Color(0xFFD97706)),
      ]),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.people), label: const Text('Manage Users'), onPressed: () => setState(() => _tab = 1))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.analytics), label: const Text('View Reports'), onPressed: () => setState(() => _tab = 4))),
        ]),
      ]))),
    ]);
  }

  Widget _buildUsersTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      DataTableWidget(
        columns: ['Name', 'Role', 'Phone', 'Actions'],
        rows: _users.where((u) => u.role != 'admin').map((u) => [
          u.name,
          BadgeWidget(status: u.role, label: u.role),
          u.phone,
          Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.receipt_long, size: 18), onPressed: () => _showPaymentHistory(u), tooltip: 'Payment History'),
            if (u.role == 'rider') IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
              onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Delete Rider'),
                content: Text('Delete ${u.name} and all their contracts?'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { Navigator.pop(context); _deleteRider(u); }, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)), child: const Text('Delete'))],
              )), tooltip: 'Delete'),
          ]),
        ]).toList(),
      ),
    ]);
  }

  Widget _buildContractsTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      DataTableWidget(
        columns: ['#', 'Rider', 'Owner', 'Amount', 'Status'],
        rows: _contracts.map((c) => [
          '#${c.contractId}',
          c.riderName.split(' ')[0],
          c.ownerName.split(' ')[0],
          'TSh ${_fmt(c.dailyAmount)}/${c.paymentType.toLowerCase()}',
          BadgeWidget(status: c.status),
        ]).toList(),
      ),
    ]);
  }

  Widget _buildPaymentsTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      DataTableWidget(
        columns: ['Rider', 'Date', 'Amount', 'Method', 'Status'],
        rows: _payments.map((p) {
          ContractModel? c;
          try { c = _contracts.firstWhere((ct) => ct.contractId == p.contractId); } catch (_) {}
          return [
            c != null ? c.riderName.split(' ')[0] : '-',
            p.date,
            'TSh ${_fmt(p.amount)}',
            p.method,
            BadgeWidget(status: p.status),
          ];
        }).toList(),
      ),
    ]);
  }

  Widget _buildReportsTab() {
    final totalPaid = _payments.where((p) => p.status == 'paid' || p.status == 'Paid').fold<int>(0, (s, p) => s + p.amount);
    final totalPending = _payments.where((p) => p.status == 'pending' || p.status == 'Pending').fold<int>(0, (s, p) => s + p.amount);
    final activeContracts = _contracts.where((c) => c.status == 'Accepted' || c.status == 'Confirmed' || c.status == 'Active').length;
    final completed = _contracts.where((c) => c.status == 'Completed').length;
    final riderCount = _users.where((u) => u.role == 'rider').length;

    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Platform Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 16),
          _reportRow('Total Riders', '$riderCount'),
          _reportRow('Active Contracts', '$activeContracts'),
          _reportRow('Completed Contracts', '$completed'),
          _reportRow('Total Revenue', 'TSh ${_fmt(totalPaid)}', color: const Color(0xFF059669)),
          _reportRow('Outstanding', 'TSh ${_fmt(totalPending)}', color: const Color(0xFFD97706)),
          const Divider(height: 24),
          const Text('Payment Breakdown', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DataTableWidget(
            columns: ['Rider', 'Total Paid', 'Balance'],
            rows: _contracts.map((c) {
              final paid = _payments.where((p) => p.contractId == c.contractId && (p.status == 'paid' || p.status == 'Paid')).fold<int>(0, (s, p) => s + p.amount);
              return [c.riderName.split(' ')[0], 'TSh ${_fmt(paid)}', 'TSh ${_fmt(c.totalAmount - paid)}'];
            }).toList(),
          ),
        ])),
      ),
    ]);
  }

  Widget _reportRow(String label, String value, {Color? color}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
    Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
    const Spacer(),
    Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color ?? Colors.black)),
  ]));

  Widget _buildProfileTab() {
    final nameCtl = TextEditingController(text: _user.name);
    final phoneCtl = TextEditingController(text: _user.phone);
    final emailCtl = TextEditingController(text: _user.email);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        CircleAvatar(radius: 36, child: Text(_user.initials, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24))),
        const SizedBox(height: 8),
        Text(_user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        Text('Administrator', style: const TextStyle(color: Color(0xFF9CA3AF))),
        const SizedBox(height: 16),
        TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: phoneCtl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: emailCtl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        FilledButton(onPressed: () {
          DbHelper.updateUser(_user.id, {'name': nameCtl.text, 'phone': phoneCtl.text, 'email': emailCtl.text});
          setState(() => _user = DbHelper.getUserById(_user.id)!);
          _toast('✅ Profile updated!');
        }, child: const Text('Save Changes')),
      ]))),
    ]);
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _TabConfig {
  final IconData icon;
  final String label;
  const _TabConfig(this.icon, this.label);
}
