import 'package:riverpod/riverpod.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/core/api_client.dart';

final contractProvider = StateNotifierProvider<ContractNotifier, ContractState>((ref) => ContractNotifier());

class ContractState {
  final List<Contract> contracts;
  final bool isLoading;
  final String? error;

  const ContractState({this.contracts = const [], this.isLoading = false, this.error});

  ContractState copyWith({List<Contract>? contracts, bool? isLoading, String? error}) =>
      ContractState(contracts: contracts ?? this.contracts, isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

class ContractNotifier extends StateNotifier<ContractState> {
  ContractNotifier() : super(const ContractState());

  Future<void> fetchByRider(String riderId) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = buildApiClient();
      final res = await dio.get('/contracts/$riderId');
      state = ContractState(contracts: (res.data as List).map((j) => Contract.fromJson(j)).toList());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = buildApiClient();
      await dio.post('/contracts', data: data);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
