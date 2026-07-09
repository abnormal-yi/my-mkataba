import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/providers/admin_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class AdminUsers extends ConsumerStatefulWidget {
  const AdminUsers({super.key});

  @override
  ConsumerState<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends ConsumerState<AdminUsers> {
  int _currentIndex = 1;
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);
    final allUsers = admin.users.isNotEmpty ? admin.users : [
      {'name': 'Sarah K.', 'role': 'Owner', 'email': 'sarah@mkataba.com', 'status': 'Active', 'contracts': '3', 'id': 'u1'},
      {'name': 'James K.', 'role': 'Rider', 'email': 'james@mkataba.com', 'status': 'Active', 'contracts': '1', 'id': 'u2'},
      {'name': 'Peter M.', 'role': 'Rider', 'email': 'peter@mkataba.com', 'status': 'Active', 'contracts': '1', 'id': 'u3'},
      {'name': 'Ali H.', 'role': 'Rider', 'email': 'ali@mkataba.com', 'status': 'Blocked', 'contracts': '1', 'id': 'u4'},
      {'name': 'John M.', 'role': 'Owner', 'email': 'john@mkataba.com', 'status': 'Active', 'contracts': '2', 'id': 'u5'},
      {'name': 'Musa J.', 'role': 'Rider', 'email': 'musa@mkataba.com', 'status': 'Expired', 'contracts': '0', 'id': 'u6'},
    ];
    final filtered = _filter == 'All' ? allUsers
        : _filter == 'Blocked' ? allUsers.where((u) => u['status'] == 'Blocked').toList()
        : allUsers.where((u) => u['role'] == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.success, elevation: 0,
        title: const Text('Users', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Owners', 'Riders', 'Blocked'].map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _filter == f ? AppColors.success : AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _filter == f ? AppColors.success : AppColors.border),
                          ),
                          child: Text(f, style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600,
                              color: _filter == f ? AppColors.white : AppColors.muted)),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                ...filtered.map((user) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _userCard(user, filtered),
                )),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex, activeColor: AppColors.success,
        items: const [
          NavItemData(icon: Icons.dashboard_outlined, label: 'Dashboard'),
          NavItemData(icon: Icons.people_outline, label: 'Users'),
          NavItemData(icon: Icons.file_present_outlined, label: 'Reports'),
          NavItemData(icon: Icons.notifications_outlined, label: 'Alerts'),
          NavItemData(icon: Icons.settings_outlined, label: 'Settings'),
        ],
        onTap: (i) {
          setState(() => _currentIndex = i);
          final routes = ['/admin/dashboard', '/admin/users', '/admin/reports', '/admin/notifications'];
          if (i < routes.length) context.go( routes[i]);
        },
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> user, List<Map<String, dynamic>> allUsers) {
    final initials = (user['name'] as String).split(' ').map((s) => s[0]).join();
    final statusColor = user['status'] == 'Active' ? AppColors.success
        : user['status'] == 'Blocked' ? AppColors.error
        : AppColors.accent;
    final roleColor = user['role'] == 'Owner' ? AppColors.accent
        : user['role'] == 'Rider' ? AppColors.primary
        : AppColors.info;
    final isBlocked = user['status'] == 'Blocked' || user['status'] == 'Expired';

    return GestureDetector(
      onTap: () => _showUserPaymentHistory(user, allUsers),
      child: ScreenCard(
        child: Row(children: [
          CircleAvatar(radius: 20, backgroundColor: roleColor.withValues(alpha: 0.2),
            child: Text(initials, style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: roleColor))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user['name']!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
              Text('${user['role']} · ${user['email']}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.muted)),
            ]),
          ),
          Text('${user['contracts']} ct', style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.muted)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(user['status']!, style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
          if (isBlocked) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _confirmDelete(user),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Rider'),
        content: Text('Remove ${user['name']} from the system? Their data will be archived but they will lose access.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminProvider.notifier).setSelectedReport('All');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${user['name']} has been removed from the system'),
                backgroundColor: AppColors.error,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showUserPaymentHistory(Map<String, dynamic> user, List<Map<String, dynamic>> allUsers) {
    final riderPayments = List.generate(15, (i) {
      final day = DateTime.now().subtract(Duration(days: 14 - i));
      final status = i > 10 ? PaymentStatus.pending : i == 2 || i == 5 ? PaymentStatus.missed : PaymentStatus.paid;
      return Payment(
        id: 'adm-p-${user['id']}-$i', contractId: 'ct-${user['id']}', date: day,
        amountPaid: status == PaymentStatus.paid ? 4000 : 0,
        targetAmount: 4000, status: status,
      );
    });
    final totalPaid = riderPayments
        .where((p) => p.status == PaymentStatus.paid)
        .fold<double>(0, (sum, p) => sum + p.amountPaid);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(children: [
                CircleAvatar(radius: 20,
                  child: Text((user['name'] as String).split(' ').map((s) => s[0]).join(),
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user['name']!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                    Text('${user['role']} · ${user['email']}',
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.muted)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Total: TSh ${totalPaid.toStringAsFixed(0)}',
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ]),
              const SizedBox(height: 16),
              const Divider(),
              ...riderPayments.reversed.map((p) {
                final color = p.status == PaymentStatus.paid ? AppColors.success
                    : p.status == PaymentStatus.missed ? AppColors.error
                    : AppColors.accent;
                final label = p.status == PaymentStatus.paid ? 'Paid'
                    : p.status == PaymentStatus.missed ? 'Missed'
                    : 'Pending';
                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Text('${p.date.day} ${months[p.date.month - 1]}',
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.darkNavy)),
                    const Spacer(),
                    Text('TSh ${p.amountPaid.toStringAsFixed(0)}',
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkNavy)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                    ),
                  ]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
