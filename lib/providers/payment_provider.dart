import 'package:riverpod/riverpod.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/core/api_client.dart';

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) => PaymentNotifier());

class PaymentState {
  final List<Payment> payments;
  final bool isLoading;
  final String? error;

  const PaymentState({this.payments = const [], this.isLoading = false, this.error});

  PaymentState copyWith({List<Payment>? payments, bool? isLoading, String? error}) =>
      PaymentState(payments: payments ?? this.payments, isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(const PaymentState());

  Future<void> fetchByContract(String contractId) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = buildApiClient();
      final res = await dio.get('/payments/$contractId');
      state = PaymentState(payments: (res.data as List).map((j) => Payment.fromJson(j)).toList());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> payViaMpesa(String phone, double amount) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = buildApiClient();
      await dio.post('/payments/mpesa/stkpush', data: {'phone': phone, 'amount': amount});
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
