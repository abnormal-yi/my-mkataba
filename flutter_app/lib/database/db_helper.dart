import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/contract_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart';
import '../models/location_model.dart';

class DbHelper {
  static late Box<String> _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>('mymkataba');
  }

  static String _k(String key) => key;

  static List<Map<String, dynamic>> _decode(String key) {
    final raw = _box.get(_k(key));
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static void _encode(String key, List<Map<String, dynamic>> data) {
    _box.put(_k(key), jsonEncode(data));
  }

  static int _nextId(String key) {
    final items = _decode(key);
    if (items.isEmpty) return 1;
    return items.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
  }

  // --- SEED ---
  static Future<void> seed() async {
    if (_box.get(_k('users')) != null) return;

    _encode('users', [
      {'id': 1, 'name': 'John Msumi', 'email': 'john@mkataba.tz', 'password': '1234', 'role': 'rider', 'initials': 'JM', 'phone': '+255 712 345 678', 'nationalId': '19900123456789', 'status': 'Active', 'region': 'Arusha', 'createdBy': 0, 'firstLogin': 0, 'photo': ''},
      {'id': 2, 'name': 'Hassan Mwangi', 'email': 'hassan@mkataba.tz', 'password': '1234', 'role': 'owner', 'initials': 'HM', 'phone': '+255 754 111 222', 'nationalId': '19880123456789', 'status': 'Active', 'region': 'Arusha', 'createdBy': 0, 'firstLogin': 0, 'photo': ''},
      {'id': 3, 'name': 'Super Creator', 'email': 'admin@mkataba.tz', 'password': '1234', 'role': 'admin', 'initials': 'SC', 'phone': '+255 800 000 000', 'nationalId': '19850123456789', 'status': 'Active', 'region': 'Arusha', 'createdBy': 0, 'firstLogin': 0, 'photo': ''},
      {'id': 4, 'name': 'Peter Njau', 'email': 'peter@mkataba.tz', 'password': '1234', 'role': 'rider', 'initials': 'PJ', 'phone': '+255 765 432 100', 'nationalId': '19920123456789', 'status': 'Overdue', 'region': 'Arusha', 'createdBy': 0, 'firstLogin': 0, 'photo': ''},
      {'id': 5, 'name': 'David Kesi', 'email': 'david@mkataba.tz', 'password': '1234', 'role': 'rider', 'initials': 'DK', 'phone': '+255 688 999 001', 'nationalId': '19930123456789', 'status': 'Pending', 'region': 'Arusha', 'createdBy': 0, 'firstLogin': 1, 'photo': ''},
      {'id': 6, 'name': 'Ali Rashid', 'email': 'ali@mkataba.tz', 'password': '1234', 'role': 'rider', 'initials': 'AR', 'phone': '+255 688 777 002', 'nationalId': '19940123456789', 'status': 'Active', 'region': 'Moshi', 'createdBy': 0, 'firstLogin': 0, 'photo': ''},
      {'id': 7, 'name': 'Grace Mbeki', 'email': 'grace@mkataba.tz', 'password': '1234', 'role': 'owner', 'initials': 'GM', 'phone': '+255 700 202 303', 'nationalId': '19870123456789', 'status': 'Active', 'region': 'Dar es Salaam', 'createdBy': 0, 'firstLogin': 0, 'photo': ''},
    ]);

    _encode('contracts', [
      {'id': 1, 'contractId': 'MK-0847', 'ownerId': 2, 'riderId': 1, 'ownerName': 'Hassan Mwangi', 'riderName': 'John Msumi', 'startDate': 'May 14, 2026', 'endDate': 'Aug 12, 2026', 'paymentType': 'Daily', 'dailyAmount': 1500, 'totalAmount': 135000, 'paidAmount': 87000, 'motorcycle': 'Bajaj Boxer 150', 'plate': 'T 245 ABZ', 'status': 'Active', 'region': 'Arusha', 'gracePeriod': 3, 'agreementText': 'I, John Msumi, agree to make daily payments of TSh 1,500 to Hassan Mwangi as per the contract terms. Failure to make payment within 3 days will result in account suspension.', 'signedDate': 'May 14, 2026 at 9:42 AM'},
      {'id': 2, 'contractId': 'MK-0831', 'ownerId': 2, 'riderId': 4, 'ownerName': 'Hassan Mwangi', 'riderName': 'Peter Njau', 'startDate': 'Apr 1, 2026', 'endDate': 'Jul 29, 2026', 'paymentType': 'Daily', 'dailyAmount': 1500, 'totalAmount': 135000, 'paidAmount': 51000, 'motorcycle': 'Bajaj Boxer 150', 'plate': 'T 246 BCY', 'status': 'Overdue', 'region': 'Arusha', 'gracePeriod': 3, 'agreementText': '', 'signedDate': 'Apr 1, 2026 at 8:00 AM'},
      {'id': 3, 'contractId': 'MK-0819', 'ownerId': 2, 'riderId': 5, 'ownerName': 'Hassan Mwangi', 'riderName': 'David Kesi', 'startDate': 'Mar 20, 2026', 'endDate': 'Jul 17, 2026', 'paymentType': 'Weekly', 'dailyAmount': 10500, 'totalAmount': 120000, 'paidAmount': 66000, 'motorcycle': 'Bajaj Boxer 150', 'plate': 'T 247 CDZ', 'status': 'Pending', 'region': 'Arusha', 'gracePeriod': 3, 'agreementText': '', 'signedDate': ''},
      {'id': 4, 'contractId': 'MK-0802', 'ownerId': 2, 'riderId': 6, 'ownerName': 'Hassan Mwangi', 'riderName': 'Ali Rashid', 'startDate': 'Mar 1, 2026', 'endDate': 'Jun 28, 2026', 'paymentType': 'Daily', 'dailyAmount': 1500, 'totalAmount': 135000, 'paidAmount': 118000, 'motorcycle': 'Bajaj Boxer 150', 'plate': 'T 248 DEF', 'status': 'Active', 'region': 'Moshi', 'gracePeriod': 3, 'agreementText': '', 'signedDate': 'Mar 1, 2026 at 7:30 AM'},
      {'id': 5, 'contractId': 'MK-0790', 'ownerId': 7, 'riderId': 0, 'ownerName': 'Grace Mbeki', 'riderName': 'Salim Omar', 'startDate': 'Feb 15, 2026', 'endDate': 'Jun 15, 2026', 'paymentType': 'Daily', 'dailyAmount': 1500, 'totalAmount': 150000, 'paidAmount': 120000, 'motorcycle': 'Bajaj Boxer 150', 'plate': 'T 249 GHI', 'status': 'Active', 'region': 'Dar es Salaam', 'gracePeriod': 3, 'agreementText': '', 'signedDate': ''},
    ]);

    _encode('notifications', [
      {'id': 1, 'userId': 1, 'type': 'missed', 'title': 'Missed Payment – June 10', 'desc': 'You missed your daily payment of TSh 1,500.', 'time': '2 days ago', 'read': 0},
      {'id': 2, 'userId': 1, 'type': 'paid', 'title': 'Payment Confirmed – June 11', 'desc': 'Your payment of TSh 1,500 was received.', 'time': 'Yesterday', 'read': 0},
      {'id': 3, 'userId': 1, 'type': 'reminder', 'title': 'Upcoming Reminder – Tomorrow', 'desc': "Don't forget your daily payment of TSh 1,500 due tomorrow.", 'time': 'Today', 'read': 0},
      {'id': 4, 'userId': 1, 'type': 'expiry', 'title': 'Contract Expiry – 61 Days Left', 'desc': 'Your contract expires on August 12, 2026.', 'time': 'Today', 'read': 0},
      {'id': 5, 'userId': 2, 'type': 'danger', 'title': 'Peter Njau – 4 Missed Payments', 'desc': "Peter has missed 4 consecutive payments.", 'time': 'Today at 8:00 AM', 'read': 0},
      {'id': 6, 'userId': 2, 'type': 'warning', 'title': 'Ali Rashid – Contract Expiring', 'desc': 'Contract #MK-0802 expires June 28, 2026.', 'time': 'Today at 7:30 AM', 'read': 0},
      {'id': 7, 'userId': 2, 'type': 'warning', 'title': 'David Kesi – Weekly Payment Due', 'desc': "David's weekly payment due today.", 'time': 'Today at 6:00 AM', 'read': 0},
    ]);

    _encode('settings', [
      {'id': 1, 'key': 'reminderDays', 'value': '1'},
      {'id': 2, 'key': 'missedBlockLimit', 'value': '3'},
      {'id': 3, 'key': 'expiryAlertDays', 'value': '14'},
      {'id': 4, 'key': 'defaultDailyRate', 'value': '1500'},
      {'id': 5, 'key': 'paymentMethods', 'value': 'M-Pesa, Tigo Pesa, Airtel Money'},
    ]);
  }

  // --- USERS ---
  static List<UserModel> getAllUsers() => _decode('users').map((m) => UserModel.fromMap(m)).toList();

  static UserModel? getUserByEmail(String email) {
    try { return getAllUsers().firstWhere((u) => u.email == email); } catch (_) { return null; }
  }

  static UserModel? getUserById(int id) {
    try { return getAllUsers().firstWhere((u) => u.id == id); } catch (_) { return null; }
  }

  static List<UserModel> getUsersByRole(String role) => getAllUsers().where((u) => u.role == role).toList();

  static UserModel createUser(String name, {String phone = '', String email = '', String nationalId = '', String region = 'Arusha', int createdBy = 0}) {
    final users = _decode('users');
    final id = _nextId('users');
    final defaultEmail = email.isNotEmpty ? email : '${name.toLowerCase().replaceAll(' ', '.')}@mkataba.tz';
    final initials = name.split(' ').map((n) => n[0]).join().toUpperCase();
    final user = {
      'id': id, 'name': name, 'email': defaultEmail, 'password': '1234',
      'role': 'rider', 'initials': initials.length > 2 ? initials.substring(0, 2) : initials,
      'phone': phone, 'nationalId': nationalId, 'status': 'Active',
      'region': region, 'createdBy': createdBy, 'firstLogin': 1, 'photo': '',
    };
    users.add(user);
    _encode('users', users);
    return UserModel.fromMap(user);
  }

  static void updateUser(int id, Map<String, dynamic> data) {
    final users = _decode('users');
    final idx = users.indexWhere((u) => u['id'] == id);
    if (idx >= 0) { users[idx].addAll(data); _encode('users', users); }
  }

  static void deleteUser(int id) { final users = _decode('users'); users.removeWhere((u) => u['id'] == id); _encode('users', users); }

  // --- CONTRACTS ---
  static List<ContractModel> getAllContracts() => _decode('contracts').map((m) => ContractModel.fromMap(m)).toList();

  static ContractModel? getContractForRider(int riderId) {
    try { return getAllContracts().firstWhere((c) => c.riderId == riderId); } catch (_) { return null; }
  }

  static List<ContractModel> getContractsForOwner(int ownerId) => getAllContracts().where((c) => c.ownerId == ownerId).toList();

  static ContractModel createContract(Map<String, dynamic> data) {
    final contracts = _decode('contracts');
    final count = contracts.length + 1;
    final cid = 'MK-${(2026000 + count).toString().padLeft(4, '0')}';
    final contract = {
      'id': _nextId('contracts'), 'contractId': cid, 'ownerId': data['ownerId'],
      'riderId': data['riderId'], 'ownerName': data['ownerName'], 'riderName': data['riderName'],
      'startDate': data['startDate'], 'endDate': data['endDate'], 'paymentType': data['paymentType'],
      'dailyAmount': data['dailyAmount'], 'totalAmount': data['totalAmount'], 'paidAmount': 0,
      'motorcycle': data['motorcycle'] as String, 'plate': (data['plate'] as String?)?.toUpperCase() ?? '', 'status': 'Pending',
      'region': data['region'] ?? 'Arusha', 'gracePeriod': data['gracePeriod'] ?? 3,
      'agreementText': data['agreementText'] ?? '', 'signedDate': '',
    };
    contracts.add(contract);
    _encode('contracts', contracts);
    return ContractModel.fromMap(contract);
  }

  static void updateContract(int id, Map<String, dynamic> data) {
    final contracts = _decode('contracts');
    final idx = contracts.indexWhere((c) => c['id'] == id);
    if (idx >= 0) { contracts[idx].addAll(data); _encode('contracts', contracts); }
  }

  static void deleteContract(String contractId) {
    final contracts = _decode('contracts');
    contracts.removeWhere((c) => c['contractId'] == contractId);
    _encode('contracts', contracts);
  }

  static void deleteContractsForRider(int riderId) {
    final contracts = _decode('contracts');
    contracts.removeWhere((c) => c['riderId'] == riderId);
    _encode('contracts', contracts);
  }

  // --- PAYMENTS ---
  static List<PaymentModel> getAllPayments() => _decode('payments').map((m) => PaymentModel.fromMap(m)).toList();

  static List<PaymentModel> getPaymentsForRider(int riderId) {
    final all = _decode('payments').map((m) => PaymentModel.fromMap(m)).toList();
    all.retainWhere((p) => p.riderId == riderId);
    all.sort((a, b) => b.id.compareTo(a.id));
    return all;
  }

  static List<PaymentModel> getPaymentsForOwner(int ownerId) {
    final all = _decode('payments').map((m) => PaymentModel.fromMap(m)).toList();
    all.retainWhere((p) => p.ownerId == ownerId);
    all.sort((a, b) => b.id.compareTo(a.id));
    return all;
  }

  static PaymentModel makePayment(int riderId, {int? customAmount}) {
    final contract = getContractForRider(riderId)!;
    final amount = customAmount ?? contract.dailyAmount;
    final newPaid = contract.paidAmount + amount;
    final now = DateTime.now();
    final dateStr = '${_month(now.month)} ${now.day}, ${now.year}';
    final isShort = amount < contract.dailyAmount;

    updateContract(contract.id, {
      'paidAmount': newPaid,
      'status': newPaid >= contract.totalAmount ? 'Completed' : contract.status,
    });

    final payments = _decode('payments');
    final pmt = {
      'id': _nextId('payments'), 'contractId': contract.contractId,
      'riderId': riderId, 'ownerId': contract.ownerId,
      'riderName': contract.riderName, 'ownerName': contract.ownerName,
      'date': dateStr, 'amount': amount, 'method': 'M-Pesa',
      'status': isShort ? 'partial' : 'paid',
    };
    payments.add(pmt);
    _encode('payments', payments);

    if (isShort) {
      final shortAmt = contract.dailyAmount - amount;
      addNotification(riderId, 'missed', 'Partial Payment — $dateStr', 'Umefaulu kulipa TSh ${_fmt(amount)} kwa leo. Kiasi pungufu TSh ${_fmt(shortAmt)}.');
      addNotification(contract.ownerId, 'missed', 'Partial Payment from ${contract.riderName}', '${contract.riderName} amelipa TSh ${_fmt(amount)} (pungufu). Anadaiwa TSh ${_fmt(shortAmt)}.');
    } else {
      addNotification(riderId, 'paid', 'Payment Confirmed – $dateStr', 'Your payment of TSh ${_fmt(amount)} was received. Thank you!');
    }

    return PaymentModel.fromMap(pmt);
  }

  static void deletePaymentsForRider(int riderId) {
    final payments = _decode('payments');
    payments.removeWhere((p) => p['riderId'] == riderId);
    _encode('payments', payments);
  }

  // --- NOTIFICATIONS ---
  static List<NotificationModel> getNotificationsForUser(int userId) {
    return _decode('notifications').map((m) => NotificationModel.fromMap(m)).where((n) => n.userId == userId).toList();
  }

  static void addNotification(int userId, String type, String title, String desc) {
    final notifications = _decode('notifications');
    notifications.add({
      'id': _nextId('notifications'), 'userId': userId, 'type': type,
      'title': title, 'desc': desc, 'time': 'Just now', 'read': 0,
    });
    _encode('notifications', notifications);
  }

  static void deleteNotificationsForUser(int userId) {
    final notifications = _decode('notifications');
    notifications.removeWhere((n) => n['userId'] == userId);
    _encode('notifications', notifications);
  }

  // --- LOCATIONS ---
  static void saveLocation(int riderId, String riderName, double lat, double lng) {
    final locations = _decode('locations');
    locations.add({
      'id': _nextId('locations'), 'riderId': riderId, 'riderName': riderName,
      'lat': lat, 'lng': lng, 'timestamp': DateTime.now().toIso8601String(),
    });
    _encode('locations', locations);
  }

  static LocationModel? getLastLocation(int riderId) {
    final all = _decode('locations').map((m) => LocationModel.fromMap(m)).toList();
    all.retainWhere((l) => l.riderId == riderId);
    if (all.isEmpty) return null;
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all.first;
  }

  static List<LocationModel> getAllLastLocations() {
    final all = _decode('locations').map((m) => LocationModel.fromMap(m)).toList();
    final Map<int, LocationModel> latest = {};
    for (final loc in all) {
      if (!latest.containsKey(loc.riderId) || loc.timestamp.compareTo(latest[loc.riderId]!.timestamp) > 0) {
        latest[loc.riderId] = loc;
      }
    }
    return latest.values.toList();
  }

  static void deleteLocationsForRider(int riderId) {
    final locations = _decode('locations');
    locations.removeWhere((l) => l['riderId'] == riderId);
    _encode('locations', locations);
  }

  // --- SETTINGS ---
  static Map<String, String> getSettings() {
    final all = _decode('settings');
    return {for (final s in all) s['key'] as String: s['value'] as String};
  }

  static void saveSettings(Map<String, String> data) {
    final settings = _decode('settings');
    for (final entry in data.entries) {
      final idx = settings.indexWhere((s) => s['key'] == entry.key);
      if (idx >= 0) { settings[idx]['value'] = entry.value; }
      else { settings.add({'id': _nextId('settings'), 'key': entry.key, 'value': entry.value}); }
    }
    _encode('settings', settings);
  }

  static List<UserModel> getRidersByOwner(int ownerId) {
    final contractRiderIds = getContractsForOwner(ownerId).map((c) => c.riderId).toSet();
    return getAllUsers().where((u) => contractRiderIds.contains(u.id) && u.role == 'rider').toList();
  }

  static List<Map<String, dynamic>> getContractApprovals(int ownerId) {
    final result = <Map<String, dynamic>>[];
    for (final c in getContractsForOwner(ownerId).where((c) => c.status == 'Accepted')) {
      final rider = getUserById(c.riderId);
      if (rider != null) result.add({'contract': c, 'rider': rider});
    }
    return result;
  }

  static void confirmContractByOwner(String contractId, int riderId) {
    confirmContract(contractId);
    updateUser(riderId, {'firstLogin': 0});
  }

  static void registerRiderWithContract({
    required String email, required String name, required String phone,
    required String password, required String nationalId,
    required int ownerId, required String ownerName,
    required String motorcycle, required String plate,
    required int dailyAmount, required int totalAmount,
    required String paymentType,
  }) {
    final users = _decode('users');
    final id = _nextId('users');
    final initials = name.split(' ').map((n) => n[0]).join().toUpperCase();
    final user = {
      'id': id, 'name': name, 'email': email, 'password': password,
      'role': 'rider', 'initials': initials.length > 2 ? initials.substring(0, 2) : initials,
      'phone': phone, 'nationalId': nationalId, 'status': 'Active',
      'region': 'Arusha', 'createdBy': ownerId, 'firstLogin': 1, 'photo': '',
    };
    users.add(user);
    _encode('users', users);

    final now = DateTime.now();
    final end = DateTime(now.year, now.month + 3, now.day);
    final m = _month;

    createContract({
      'ownerId': ownerId, 'riderId': id, 'ownerName': ownerName,
      'riderName': name, 'startDate': '${m(now.month)} ${now.day}, ${now.year}',
      'endDate': '${m(end.month)} ${end.day}, ${end.year}',
      'paymentType': paymentType, 'dailyAmount': dailyAmount,
      'totalAmount': totalAmount, 'motorcycle': motorcycle, 'plate': plate,
    });
  }

  // --- ACTIONS ---
  static void acceptContract(String contractId, int riderId) {
    final contract = getAllContracts().firstWhere((c) => c.contractId == contractId);
    final now = DateTime.now();
    final signed = '${_month(now.month)} ${now.day}, ${now.year} at ${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour < 12 ? 'AM' : 'PM'}';
    updateContract(contract.id, {'status': 'Accepted', 'signedDate': signed});
    addNotification(riderId, 'paid', 'Contract Accepted', 'You accepted contract #$contractId. Change your password to continue.');
    addNotification(contract.ownerId, 'warning', 'Rider Accepted – #$contractId', '${contract.riderName} accepted the contract. Confirm to activate.');
  }

  static void rejectContract(String contractId, int riderId) {
    final contract = getAllContracts().firstWhere((c) => c.contractId == contractId);
    updateContract(contract.id, {'status': 'Rejected'});
    addNotification(riderId, 'missed', 'Contract Rejected', 'You rejected contract #$contractId.');
    addNotification(contract.ownerId, 'danger', 'Rider Rejected – #$contractId', '${contract.riderName} rejected the contract.');
  }

  static void confirmContract(String contractId) {
    final contract = getAllContracts().firstWhere((c) => c.contractId == contractId);
    updateContract(contract.id, {'status': 'Active'});
    addNotification(contract.riderId, 'paid', 'Contract Active!', 'Your contract #$contractId is now active. Start making payments.');
    addNotification(contract.ownerId, 'paid', 'Contract Confirmed', 'Contract #$contractId with ${contract.riderName} is now active.');
  }

  static void blockRider(int riderId) {
    updateUser(riderId, {'status': 'Blocked'});
    final contracts = _decode('contracts');
    for (int i = 0; i < contracts.length; i++) {
      if (contracts[i]['riderId'] == riderId) contracts[i]['status'] = 'Blocked';
    }
    _encode('contracts', contracts);
    addNotification(riderId, 'missed', 'Account Suspended', 'Your account has been blocked due to missed payments.');
  }

  static void deleteRider(int riderId) {
    deleteUser(riderId);
    final contracts = _decode('contracts');
    contracts.removeWhere((c) => c['riderId'] == riderId);
    _encode('contracts', contracts);
    deletePaymentsForRider(riderId);
    deleteNotificationsForUser(riderId);
    deleteLocationsForRider(riderId);
  }

  static void changePassword(int userId, String newPassword) {
    updateUser(userId, {'password': newPassword, 'firstLogin': 0});
  }

  static void resetDatabase() async {
    await _box.clear();
    await seed();
  }

  static String _month(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];
  static String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
