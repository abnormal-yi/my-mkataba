import 'package:riverpod/riverpod.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/core/api_client.dart';

final riderSummaryProvider = StateNotifierProvider<RiderSummaryNotifier, RiderSummaryState>((ref) => RiderSummaryNotifier());

class RiderSummaryState {
  final List<RiderSummary> riders;
  final bool isLoading;
  final String? error;

  const RiderSummaryState({this.riders = const [], this.isLoading = false, this.error});

  RiderSummaryState copyWith({List<RiderSummary>? riders, bool? isLoading, String? error}) =>
      RiderSummaryState(riders: riders ?? this.riders, isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

class RiderSummaryNotifier extends StateNotifier<RiderSummaryState> {
  RiderSummaryNotifier() : super(RiderSummaryState(
    riders: const [
      RiderSummary(riderId: 'rider-001', riderName: 'James K.', vehiclePlate: 'T 123 ABC',
          contractStatus: ContractStatus.active, daysRemaining: 33, balanceRemaining: 132000, missedPayments: 2),
      RiderSummary(riderId: 'rider-002', riderName: 'Peter M.', vehiclePlate: 'T 456 DEF',
          contractStatus: ContractStatus.active, daysRemaining: 58, balanceRemaining: 88000, missedPayments: 0),
      RiderSummary(riderId: 'rider-003', riderName: 'Ali H.', vehiclePlate: 'T 789 GHI',
          contractStatus: ContractStatus.blocked, daysRemaining: 12, balanceRemaining: 56000, missedPayments: 5, isBlocked: true),
    ],
  ));

  Future<void> fetchByOwner(String ownerId) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = buildApiClient();
      final res = await dio.get('/owners/$ownerId/riders');
      state = RiderSummaryState(riders: (res.data as List).map((j) => RiderSummary.fromJson(j)).toList());
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}
