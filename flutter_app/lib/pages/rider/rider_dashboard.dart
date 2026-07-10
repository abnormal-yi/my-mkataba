import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../database/db_helper.dart';
import '../../models/user_model.dart';
import '../../models/contract_model.dart';
import '../../models/payment_model.dart';
import '../../models/notification_model.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/badge.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/data_table.dart';
import '../../widgets/notification_item.dart';
import '../../widgets/toast.dart';
import '../login_page.dart';

class RiderDashboard extends StatefulWidget {
  final UserModel user;
  const RiderDashboard({super.key, required this.user});
  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard> {
  late UserModel _user;
  int _tab = 0;
  ContractModel? _contract;
  List<PaymentModel> _payments = [];
  List<NotificationModel> _notifications = [];
  String _step = '';
  String _toastMsg = '';
  Timer? _toastTimer;
  String _lastShared = '';

  final List<_TabConfig> _tabs = const [
    _TabConfig(Icons.dashboard, 'Overview'),
    _TabConfig(Icons.description, 'Contract'),
    _TabConfig(Icons.payment, 'Payments'),
    _TabConfig(Icons.location_on, 'Location'),
    _TabConfig(Icons.notifications, 'Alerts'),
    _TabConfig(Icons.person, 'Profile'),
  ];

  @override
  void initState() { _user = widget.user; _loadData(); super.initState(); }

  void _loadData() {
    setState(() {
      _contract = DbHelper.getContractForRider(_user.id);
      _payments = DbHelper.getPaymentsForRider(_user.id);
      _notifications = DbHelper.getNotificationsForUser(_user.id);
      if (_user.firstLogin && _contract != null && _contract!.status == 'Pending') {
        _step = 'accept';
      } else if (_user.firstLogin && _contract != null && _contract!.status == 'Accepted') {
        _step = 'changepwd';
      } else { _step = 'done'; }
    });
    final last = DbHelper.getLastLocation(_user.id);
    if (last != null) _lastShared = '${DateTime.parse(last.timestamp).toIso8601String().substring(11, 19)}';
  }

  void _toast(String msg) {
    _toastTimer?.cancel();
    setState(() => _toastMsg = msg);
    _toastTimer = Timer(const Duration(seconds: 3), () { if (mounted) setState(() => _toastMsg = ''); });
  }

  void _acceptContract() {
    DbHelper.acceptContract(_contract!.contractId, _user.id);
    _toast('✅ Contract accepted! Now set your new password.');
    setState(() => _step = 'changepwd');
  }

  void _rejectContract() {
    DbHelper.rejectContract(_contract!.contractId, _user.id);
    _toast('⛔ Contract rejected. Owner notified.');
    setState(() => _step = 'done');
  }

  final _pwdCtl = TextEditingController();
  void _changePassword() {
    if (_pwdCtl.text.length < 4) { _toast('⚠️ Password must be at least 4 characters'); return; }
    DbHelper.changePassword(_user.id, _pwdCtl.text);
    DbHelper.updateUser(_user.id, {'firstLogin': 0});
    setState(() { _user = DbHelper.getUserById(_user.id)!; _step = 'done'; });
    _toast('✅ Password changed! Welcome to My Mkataba 🎉');
  }

  int _payAmount = 1500;
  void _makePayment() {
    if (_payAmount < 100) { _toast('⚠️ Kiasi lazima kiwe angalau TSh 100'); return; }
    final daily = _contract?.dailyAmount ?? 1500;
    final actual = _payAmount < daily ? _payAmount : daily;
    DbHelper.makePayment(_user.id, customAmount: actual);
    final isShort = actual < daily;
    _toast(isShort ? '✅ Umelipa TSh ${_fmt(actual)} (pungufu). Owner amejulishwa.' : '✅ Payment of TSh ${_fmt(actual)} sent!');
    _loadData();
  }

  void _shareLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) { _toast('⚠️ GPS haipo kwenye kifaa hiki'); return; }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) { _toast('⚠️ Umekataa ruhusa ya GPS'); return; }
    }
    if (perm == LocationPermission.deniedForever) { _toast('⚠️ Ruhusa ya GPS imekataliwa kabisa. Badilisha kwenye mipangilio.'); return; }
    _toast('📍 Inatafuta location...');
    try {
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 30)));
      DbHelper.saveLocation(_user.id, _user.name, pos.latitude, pos.longitude);
      _lastShared = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      _toast('✅ Location imesharewa!');
    } catch (e) {
      _toast('⚠️ GPS timeout. Jaribu tena mahali wazi.');
    }
  }

  void _uploadPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 300, maxHeight: 300, imageQuality: 50);
    if (img != null) {
      final bytes = await img.readAsBytes();
      final b64 = base64Encode(bytes);
      DbHelper.updateUser(_user.id, {'photo': 'data:image/jpeg;base64,$b64'});
      setState(() => _user = DbHelper.getUserById(_user.id)!);
      _toast('✅ Photo updated!');
    }
  }

  void _saveProfile(String name, String phone, String email, String nationalId) {
    DbHelper.updateUser(_user.id, {'name': name, 'phone': phone, 'email': email, 'nationalId': nationalId});
    setState(() => _user = DbHelper.getUserById(_user.id)!);
    _toast('✅ Profile updated!');
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 'accept') return _buildFirstFlow('📄', 'New Contract Available', 'Review and accept your contract to start', _buildContractCard());
    if (_step == 'changepwd') return _buildFirstFlow('🔐', 'Change Your Password', 'Set a new password to secure your account', _buildPwdCard());

    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'Good ${DateTime.now().hour < 12 ? 'morning' : 'afternoon'}, ${_user.name.split(' ')[0]} 👋' : _tabs[_tab].label),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())))],
      ),
      body: Stack(children: [
        _buildTabContent(),
        if (_toastMsg.isNotEmpty) ToastWidget(message: _toastMsg),
      ]),
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
      case 1: return _buildContractTab();
      case 2: return _buildPaymentsTab();
      case 3: return _buildLocationTab();
      case 4: return _buildNotificationsTab();
      case 5: return _buildProfileTab();
      default: return const SizedBox();
    }
  }

  Widget _buildOverview() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Here\'s your contract summary for today', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
      const SizedBox(height: 16),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.6, mainAxisSpacing: 10, crossAxisSpacing: 10, children: [
        StatCard(label: 'Contract Status', value: BadgeWidget(status: _contract?.status ?? 'pending'), note: _contract != null ? 'Expires ${_contract!.endDate}' : 'No contract'),
        StatCard(label: 'Amount Paid', value: 'TSh ${_fmt(_contract?.paidAmount ?? 0)}', note: _contract != null ? 'of TSh ${_fmt(_contract!.totalAmount)} total' : '', color: const Color(0xFF059669)),
        StatCard(label: 'Balance Due', value: 'TSh ${_fmt((_contract?.totalAmount ?? 0) - (_contract?.paidAmount ?? 0))}', note: 'Pending', color: const Color(0xFFD97706)),
      ]),
      if (_contract != null) ...[
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Text('Payment Progress', style: TextStyle(fontWeight: FontWeight.w700)), const Spacer(), BadgeWidget(status: _contract!.paymentType, label: '${_contract!.paymentType} – TSh ${_fmt(_contract!.dailyAmount)}/${_contract!.paymentType.toLowerCase()}')]),
          const SizedBox(height: 12),
          Row(children: [Text('Paid: TSh ${_fmt(_contract!.paidAmount)}', style: const TextStyle(color: Color(0xFF059669))), const Spacer(), Text('Remaining: TSh ${_fmt(_contract!.totalAmount - _contract!.paidAmount)}', style: const TextStyle(color: Color(0xFFDC2626)))]),
          const SizedBox(height: 8),
          ProgressBarWidget(value: (_contract!.paidAmount / _contract!.totalAmount * 100).toDouble()),
          Text('${(_contract!.paidAmount / _contract!.totalAmount * 100).round()}% complete', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ]))),
        const SizedBox(height: 8),
        FilledButton.icon(
          icon: const Icon(Icons.payment),
          label: Text('Pay Now via M-Pesa'),
          onPressed: () => showDialog(context: context, builder: (_) => _buildPayModal()),
        ),
      ],
    ]);
  }

  Widget _buildPayModal() {
    final daily = _contract?.dailyAmount ?? 1500;
    return AlertDialog(
      title: const Text('Make Payment'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Daily amount: TSh ${_fmt(daily)}', style: const TextStyle(color: Color(0xFF9CA3AF))),
        const SizedBox(height: 12),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount to Pay (TSh)', border: OutlineInputBorder()),
          controller: TextEditingController(text: _payAmount.toString()),
          onChanged: (v) => _payAmount = int.tryParse(v) ?? daily,
        ),
        if (_payAmount < daily) const Padding(padding: EdgeInsets.only(top: 4), child: Text('⚠️ Utalipa kiasi pungufu. Owner atajulishwa.', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () { Navigator.pop(context); _makePayment(); }, child: Text('Pay TSh ${_fmt(_payAmount)}')),
      ],
    );
  }

  Widget _buildContractTab() {
    if (_contract == null) return const Center(child: Text('No contract found.', style: TextStyle(color: Color(0xFF9CA3AF))));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('Contract #${_contract!.contractId}', style: const TextStyle(fontWeight: FontWeight.w700)), const Spacer(), BadgeWidget(status: _contract!.status)]),
        const Divider(),
        _detailRow('Owner', _contract!.ownerName),
        _detailRow('Rider', _contract!.riderName),
        _detailRow('Start Date', _contract!.startDate),
        _detailRow('End Date', _contract!.endDate),
        _detailRow('Payment Type', _contract!.paymentType),
        _detailRow('Motorcycle', _contract!.motorcycle),
        _detailRow('Amount', 'TSh ${_fmt(_contract!.dailyAmount)}/${_contract!.paymentType.toLowerCase()}'),
        _detailRow('Total Amount', 'TSh ${_fmt(_contract!.totalAmount)}'),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Digital Agreement', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(_contract!.agreementText.isNotEmpty ? _contract!.agreementText : 'No agreement text available.', style: const TextStyle(color: Color(0xFF6B7280))),
        if (_contract!.signedDate.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [const Icon(Icons.check_circle, color: Color(0xFF059669)), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Agreement Accepted', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669))),
              Text('Signed digitally on ${_contract!.signedDate}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ])])),
        ],
      ]))),
    ]);
  }

  Widget _buildPaymentsTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(8), child: DataTableWidget(
        columns: const ['Date', 'Amount', 'Method', 'Status'],
        rows: _payments.map((p) => [p.date, 'TSh ${_fmt(p.amount)}', p.method, BadgeWidget(status: p.status)]).toList(),
      ))),
      if (_payments.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No payments yet.', style: TextStyle(color: Color(0xFF9CA3AF))))),
    ]);
  }

  Widget _buildLocationTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: Padding(padding: EdgeInsets.all(40), child: Column(children: [
        Icon(Icons.location_on, size: 48, color: Color(0xFF6C3FC5)),
        SizedBox(height: 16),
        Text('Press the button below to share your current location with your owner.', style: TextStyle(color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
      ]))),
      const SizedBox(height: 12),
      FilledButton.icon(icon: const Icon(Icons.my_location), label: const Text('📍 Share My Location'), onPressed: _shareLocation),
      if (_lastShared.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text('✓ Last shared: $_lastShared', style: const TextStyle(color: Color(0xFF059669), fontSize: 12))),
    ]);
  }

  Widget _buildNotificationsTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (_notifications.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No notifications.', style: TextStyle(color: Color(0xFF9CA3AF))))),
      ..._notifications.map((n) => NotificationItemWidget(item: n)),
    ]);
  }

  Widget _buildProfileTab() {
    final nameCtl = TextEditingController(text: _user.name);
    final phoneCtl = TextEditingController(text: _user.phone);
    final emailCtl = TextEditingController(text: _user.email);
    final idCtl = TextEditingController(text: _user.nationalId);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: _uploadPhoto,
            child: CircleAvatar(
              radius: 32,
              backgroundImage: _user.photo != null && _user.photo!.isNotEmpty ? MemoryImage(_base64Decode(_user.photo!)) : null,
              child: (_user.photo == null || _user.photo!.isEmpty) ? Text(_user.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)) : null,
            ),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextButton.icon(icon: const Icon(Icons.camera_alt, size: 16), label: const Text('Change Photo', style: TextStyle(fontSize: 12)), onPressed: _uploadPhoto),
            Text(_user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            Text(_user.role, style: const TextStyle(color: Color(0xFF9CA3AF))),
          ]),
        ]),
        const SizedBox(height: 16),
        TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: phoneCtl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: emailCtl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: idCtl, decoration: const InputDecoration(labelText: 'National ID', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => _saveProfile(nameCtl.text, phoneCtl.text, emailCtl.text, idCtl.text), child: const Text('Save Changes')),
      ]))),
    ]);
  }

  Widget _buildFirstFlow(String icon, String title, String sub, Widget card) {
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 56)), const SizedBox(height: 16),
      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      Text(sub, style: const TextStyle(color: Color(0xFF9CA3AF))), const SizedBox(height: 24),
      card,
    ])))));
  }

  Widget _buildContractCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFF6C3FC5), width: 2)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('Contract #${_contract!.contractId}', style: const TextStyle(fontWeight: FontWeight.w700)), const Spacer(), BadgeWidget(status: _contract!.paymentType)]),
        const SizedBox(height: 12),
        _detailRow('Owner', _contract!.ownerName), _detailRow('Rider', _contract!.riderName),
        _detailRow('Motorcycle', _contract!.motorcycle),
        _detailRow('Payment', 'TSh ${_fmt(_contract!.dailyAmount)}/${_contract!.paymentType.toLowerCase()}'),
        _detailRow('Total', 'TSh ${_fmt(_contract!.totalAmount)}'),
        _detailRow('Duration', '${_contract!.startDate} – ${_contract!.endDate}'),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F7FF), borderRadius: BorderRadius.circular(10)),
          child: Text(_contract!.agreementText.isNotEmpty ? _contract!.agreementText : 'Standard Boda Boda contract agreement.', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: FilledButton(onPressed: _acceptContract, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF059669)), child: const Text('✅ Accept Contract'))),
          const SizedBox(width: 12),
          Expanded(child: FilledButton(onPressed: _rejectContract, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)), child: const Text('✕ Reject'))),
        ]),
      ])),
    );
  }

  Widget _buildPwdCard() {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(controller: TextEditingController(text: '1234'), enabled: false, decoration: const InputDecoration(labelText: 'Default Password')),
      const SizedBox(height: 12),
      TextField(controller: _pwdCtl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password', hintText: 'Min 4 characters')),
      const SizedBox(height: 16),
      FilledButton(onPressed: _changePassword, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF059669)), child: const Text('✅ Save & Continue')),
      const SizedBox(height: 12),
      const Text('Owner has been notified to confirm the contract.', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
    ])));
  }

  Widget _detailRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]));
  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  Uint8List _base64Decode(String dataUri) {
    final parts = dataUri.split(',');
    if (parts.length < 2) return Uint8List(0);
    return base64Decode(parts[1]);
  }
}

class _TabConfig {
  final IconData icon;
  final String label;
  const _TabConfig(this.icon, this.label);
}
