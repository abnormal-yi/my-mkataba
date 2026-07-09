import 'package:riverpod/riverpod.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/core/api_client.dart';

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) => AdminNotifier());

class AdminState {
  final SystemStats? stats;
  final List<Map<String, String>> users;
  final Map<String, List<Map<String, String>>> reports;
  final bool isLoading;
  final String? error;
  final String selectedReport;

  const AdminState({
    this.stats, this.users = const [], this.reports = const {},
    this.isLoading = false, this.error, this.selectedReport = 'Unpaid Contracts',
  });

  AdminState copyWith({
    SystemStats? stats, List<Map<String, String>>? users,
    Map<String, List<Map<String, String>>>? reports,
    bool? isLoading, String? error, String? selectedReport,
  }) => AdminState(
    stats: stats ?? this.stats, users: users ?? this.users,
    reports: reports ?? this.reports, isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error, selectedReport: selectedReport ?? this.selectedReport,
  );
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(AdminState(
    stats: const SystemStats(
      totalUsers: 156, totalOwners: 12, totalRiders: 143,
      activeContracts: 89, expiredContracts: 23, blockedContracts: 7,
      totalRevenue: 2400000,
    ),
    users: [
      {'name': 'Sarah K.', 'role': 'Owner', 'email': 'sarah@mkataba.com', 'status': 'Active', 'contracts': '4'},
      {'name': 'John M.', 'role': 'Owner', 'email': 'john@mkataba.com', 'status': 'Active', 'contracts': '2'},
      {'name': 'James K.', 'role': 'Rider', 'email': 'james@mkataba.com', 'status': 'Active', 'contracts': '1'},
      {'name': 'Peter M.', 'role': 'Rider', 'email': 'peter@mkataba.com', 'status': 'Active', 'contracts': '1'},
      {'name': 'Ali H.', 'role': 'Rider', 'email': 'ali@mkataba.com', 'status': 'Blocked', 'contracts': '1'},
      {'name': 'Musa J.', 'role': 'Rider', 'email': 'musa@mkataba.com', 'status': 'Active', 'contracts': '1'},
    ],
    reports: {
      'Unpaid Contracts': [
        {'owner': 'Sarah K.', 'rider': 'James K.', 'plate': 'T 123 ABC', 'balance': 'TSh 132,000', 'days': '33'},
        {'owner': 'John M.', 'rider': 'Ali H.', 'plate': 'T 789 GHI', 'balance': 'TSh 56,000', 'days': '12'},
      ],
      'Expired Contracts': [
        {'owner': 'Sarah K.', 'rider': 'Musa J.', 'plate': 'T 321 CBA', 'balance': 'TSh 0', 'days': '0'},
      ],
      'Active Contracts': [
        {'owner': 'Sarah K.', 'rider': 'James K.', 'plate': 'T 123 ABC', 'balance': 'TSh 132,000', 'days': '33'},
        {'owner': 'Sarah K.', 'rider': 'Peter M.', 'plate': 'T 456 DEF', 'balance': 'TSh 88,000', 'days': '58'},
        {'owner': 'John M.', 'rider': 'Ali H.', 'plate': 'T 789 GHI', 'balance': 'TSh 56,000', 'days': '12'},
      ],
      'All Contracts': [
        {'owner': 'Sarah K.', 'rider': 'James K.', 'plate': 'T 123 ABC', 'balance': 'TSh 132,000', 'days': '33'},
        {'owner': 'Sarah K.', 'rider': 'Peter M.', 'plate': 'T 456 DEF', 'balance': 'TSh 88,000', 'days': '58'},
        {'owner': 'John M.', 'rider': 'Ali H.', 'plate': 'T 789 GHI', 'balance': 'TSh 56,000', 'days': '12'},
        {'owner': 'Sarah K.', 'rider': 'Musa J.', 'plate': 'T 321 CBA', 'balance': 'TSh 0', 'days': '0'},
      ],
    },
  ));

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = buildApiClient();
      final res = await dio.get('/admin/stats');
      state = state.copyWith(stats: SystemStats.fromJson(res.data), isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = buildApiClient();
      final res = await dio.get('/admin/users');
      state = state.copyWith(
        users: (res.data as List).map((j) => Map<String, String>.from(j)).toList(),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setSelectedReport(String report) {
    state = state.copyWith(selectedReport: report);
  }
}
