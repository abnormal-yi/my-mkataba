import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/user_model.dart';
import '../../models/contract_model.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/badge.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/data_table.dart';
import '../../widgets/toast.dart';
import '../login_page.dart';

class OwnerDashboard extends StatefulWidget {
  final UserModel user;
  const OwnerDashboard({super.key, required this.user});
  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  late UserModel _user;
  int _tab = 0;
  List<ContractModel> _contracts = [];
  List<UserModel> _riders = [];
  List<Map<String,dynamic>> _pendingApprovals = [];
  String _toastMsg = '';

  final List<_TabConfig> _tabs = const [
    _TabConfig(Icons.dashboard, 'Overview'),
    _TabConfig(Icons.people, 'Riders'),
    _TabConfig(Icons.add_circle_outline, 'Register'),
    _TabConfig(Icons.checklist, 'Approvals'),
    _TabConfig(Icons.receipt_long, 'Reports'),
    _TabConfig(Icons.person, 'Profile'),
  ];

  @override
  void initState() { _user = widget.user; _loadData(); super.initState(); }

  void _loadData() {
    _contracts = DbHelper.getContractsForOwner(_user.id);
    _riders = DbHelper.getRidersByOwner(_user.id);
    _pendingApprovals = DbHelper.getContractApprovals(_user.id);
    setState(() {});
  }

  void _toast(String msg) { setState(() => _toastMsg = msg); Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _toastMsg = ''); }); }

  void _confirmContract(String cid, int uid) {
    DbHelper.confirmContractByOwner(cid, uid);
    _toast('✅ Contract confirmed! Rider can now use the app.');
    _loadData();
  }

  void _rejectContractByOwner(String cid) {
    DbHelper.deleteContract(cid);
    _toast('Contract rejected and removed.');
    _loadData();
  }

  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController(text: '1234');
  final _nidCtl = TextEditingController();
  final _motoCtl = TextEditingController();
  final _plateCtl = TextEditingController();
  String _paymentType = 'Daily';

  void _registerRider() {
    if (!_formKey.currentState!.validate()) return;
    final existing = DbHelper.getUserByEmail(_emailCtl.text.trim());
    if (existing != null) { _toast('⚠️ Email already registered'); return; }
    DbHelper.registerRiderWithContract(
      email: _emailCtl.text.trim(),
      name: _nameCtl.text.trim(),
      phone: _phoneCtl.text.trim(),
      password: _passCtl.text,
      nationalId: _nidCtl.text.trim(),
      ownerId: _user.id,
      ownerName: _user.name,
      motorcycle: _motoCtl.text.trim(),
      plate: _plateCtl.text.trim(),
      dailyAmount: 1500,
      totalAmount: 135000,
      paymentType: _paymentType,
    );
    _toast('✅ Rider registered! Pending approval.');
    _loadData();
    _nameCtl.clear(); _phoneCtl.clear(); _emailCtl.clear(); _passCtl.text = '1234';
    _nidCtl.clear(); _motoCtl.clear(); _plateCtl.clear();
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
      case 1: return _buildRiders();
      case 2: return _buildRegister();
      case 3: return _buildApprovals();
      case 4: return _buildReports();
      case 5: return _buildProfile();
      default: return const SizedBox();
    }
  }

  Widget _buildOverview() {
    final active = _contracts.where((c) => c.status == 'Accepted' || c.status == 'Confirmed' || c.status == 'Active').length;
    final pending = _pendingApprovals.length;
    final payments = DbHelper.getAllPayments().where((p) => _contracts.any((c) => c.contractId == p.contractId)).toList();
    final riderPayments = payments.where((p) => p.status == 'paid' || p.status == 'Paid').fold<int>(0, (s, p) => s + p.amount);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Manage your fleet and track earnings', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
      const SizedBox(height: 16),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.6, mainAxisSpacing: 10, crossAxisSpacing: 10, children: [
        StatCard(label: 'Active Riders', value: active, note: 'out of ${_riders.length} total', color: const Color(0xFF6C3FC5)),
        StatCard(label: 'Pending Approvals', value: pending, note: 'need review', color: pending > 0 ? const Color(0xFFD97706) : const Color(0xFF059669)),
        StatCard(label: 'Total Collected', value: 'TSh ${_fmt(riderPayments)}', note: 'from all riders', color: const Color(0xFF059669)),
        StatCard(label: 'Contracts Active', value: active, note: 'completed: ${_contracts.where((c) => c.status == 'Completed').length}', color: const Color(0xFF2563EB)),
      ]),
      if (_contracts.isNotEmpty) ...[
        const SizedBox(height: 16),
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Revenue Overview', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _contracts.length, itemBuilder: (_, i) {
                final c = _contracts[i];
                final pct = c.totalAmount > 0 ? (c.paidAmount / c.totalAmount * 100).round() : 0;
                return Container(width: 140, margin: const EdgeInsets.only(right: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('#${c.contractId} - ${c.riderName.split(' ')[0]}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  ProgressBarWidget(value: pct.toDouble(), color: pct >= 100 ? const Color(0xFF059669) : const Color(0xFF6C3FC5)),
                  Text('$pct% - TSh ${_fmt(c.paidAmount)}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                ]));
              }),
            ),
          ])),
        ),
      ],
    ]);
  }

  Widget _buildRiders() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (_riders.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No riders registered.', style: TextStyle(color: Color(0xFF9CA3AF))))),
      ..._riders.map((r) {
        final c = _contracts.where((c) => c.riderId == r.id).toList();
        return Card(child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFF3F0FF),
            child: Text(r.initials, style: const TextStyle(color: Color(0xFF6C3FC5), fontWeight: FontWeight.w800)),
          ),
          title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${r.phone}  |  ${c.length} contract(s)'),
          trailing: BadgeWidget(status: c.isNotEmpty ? c.last.status : 'pending'),
          onTap: () => _showRiderDetail(r),
        ));
      }),
    ]);
  }

  void _showRiderDetail(UserModel rider) {
    final payments = DbHelper.getPaymentsForRider(rider.id);
    showModalBottomSheet(context: context, builder: (_) => SizedBox(
      height: MediaQuery.of(context).size.height * .75,
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(rider.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        Text(rider.phone, style: const TextStyle(color: Color(0xFF9CA3AF))),
        const SizedBox(height: 12),
        const Text('Payment History', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
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

  Widget _buildRegister() {
    return Form(
      key: _formKey,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const Card(child: Padding(padding: EdgeInsets.all(40), child: Column(children: [
          Icon(Icons.person_add, size: 48, color: Color(0xFF6C3FC5)),
          SizedBox(height: 16),
          Text('Fill in the details below to register a new rider', style: TextStyle(color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
        ]))),
        const SizedBox(height: 12),
        TextFormField(controller: _nameCtl, validator: (v) => v == null || v.isEmpty ? 'Required' : null, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: _phoneCtl, validator: (v) => v == null || v.isEmpty ? 'Required' : null, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: _emailCtl, validator: (v) => v == null || v.isEmpty ? 'Required' : null, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: _passCtl, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), hintText: 'Default: 1234')),
        const SizedBox(height: 12),
        TextFormField(controller: _nidCtl, decoration: const InputDecoration(labelText: 'National ID', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: _motoCtl, decoration: const InputDecoration(labelText: 'Motorcycle Model', hintText: 'e.g., Bajaj Boxer 150', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: _plateCtl, decoration: const InputDecoration(labelText: 'Plate Number', hintText: 'e.g., T 245 ABZ', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(labelText: 'Payment Type', border: OutlineInputBorder()),
          child: DropdownButtonHideUnderline(child: DropdownButton(
            value: _paymentType,
            items: ['Daily', 'Weekly', 'Monthly'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _paymentType = v!),
          )),
        ),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          const Icon(Icons.info_outline, size: 20, color: Color(0xFF6C3FC5)),
          const SizedBox(width: 8),
          Expanded(child: Text('Default daily: TSh 1,500 | Total: TSh 135,000 (90 days). Owners can adjust later.', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12))),
        ]))),
        const SizedBox(height: 16),
        SizedBox(height: 48, child: FilledButton(onPressed: _registerRider, child: const Text('Register Rider', style: TextStyle(fontSize: 16)))),
      ]),
    );
  }

  Widget _buildApprovals() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (_pendingApprovals.isEmpty) Center(
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(40), child: Column(children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFF3F0FF), borderRadius: BorderRadius.circular(100)),
              child: const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF059669))),
            const SizedBox(height: 16),
            const Text('No pending approvals', style: TextStyle(color: Color(0xFF9CA3AF))),
          ])),
        ]),
      ),
      ..._pendingApprovals.map((item) {
        final c = item['contract'] as ContractModel;
        final r = item['rider'] as UserModel;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFD97706), width: 2)),
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [CircleAvatar(child: Text(r.initials)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(r.phone, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            ])), BadgeWidget(status: 'Pending')]),
            const Divider(),
            _detailRow('Contract', '#${c.contractId}'),
            _detailRow('Amount', 'TSh ${_fmt(c.dailyAmount)}/${c.paymentType.toLowerCase()}'),
            _detailRow('Total', 'TSh ${_fmt(c.totalAmount)}'),
            _detailRow('Motorcycle', c.motorcycle),
            _detailRow('Plate', c.plate),
            Text(c.agreementText.isNotEmpty ? c.agreementText : 'Standard agreement', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: FilledButton(onPressed: () => _confirmContract(c.contractId, r.id), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF059669)), child: const Text('✅ Confirm'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: () => _rejectContractByOwner(c.contractId), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)), child: const Text('✕ Reject'))),
            ]),
          ])),
        );
      }),
    ]);
  }

  Widget _buildReports() {
    final payments = DbHelper.getAllPayments().where((p) => _contracts.any((c) => c.contractId == p.contractId)).toList();
    final paid = payments.where((p) => p.status == 'paid' || p.status == 'Paid').fold<int>(0, (s, p) => s + p.amount);
    final pendingAmount = payments.where((p) => p.status == 'pending' || p.status == 'Pending').fold<int>(0, (s, p) => s + p.amount);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [Expanded(child: StatCard(label: 'Collected', value: 'TSh ${_fmt(paid)}', color: const Color(0xFF059669))),
          Expanded(child: StatCard(label: 'Outstanding', value: 'TSh ${_fmt(pendingAmount)}', color: const Color(0xFFD97706)))]),
        const SizedBox(height: 16),
        const Text('Payment History', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8),
        DataTableWidget(
          columns: ['Rider', 'Date', 'Amount', 'Status'],
          rows: payments.map((p) {
            final contract = _contracts.firstWhere((c) => c.contractId == p.contractId, orElse: () => ContractModel.empty());
            return [contract.riderName.isNotEmpty ? contract.riderName.split(' ')[0] : '-', p.date, 'TSh ${_fmt(p.amount)}', BadgeWidget(status: p.status)];
          }).toList(),
        ),
      ]))),
    ]);
  }

  Widget _buildProfile() {
    final nameCtl = TextEditingController(text: _user.name);
    final phoneCtl = TextEditingController(text: _user.phone);
    final emailCtl = TextEditingController(text: _user.email);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        CircleAvatar(radius: 36, child: Text(_user.initials, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24))),
        const SizedBox(height: 8),
        Text(_user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
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

  Widget _detailRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]));
  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _TabConfig {
  final IconData icon;
  final String label;
  const _TabConfig(this.icon, this.label);
}
