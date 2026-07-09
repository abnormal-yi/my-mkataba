import 'package:flutter_riverpod/flutter_riverpod.dart';
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

double _totalPaidForContract(List<Payment> payments, String contractId) =>
    payments.where((p) => p.contractId == contractId && p.status == PaymentStatus.paid)
        .fold<double>(0, (s, p) => s + p.amountPaid);

double _totalPaidForRider(List<Payment> payments, String riderId) =>
    payments.where((p) => p.riderId == riderId && p.status == PaymentStatus.paid)
        .fold<double>(0, (s, p) => s + p.amountPaid);

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(PaymentState(payments: _initialPayments));

  static final List<Payment> _initialPayments = [
    Payment(id: 'p1', contractId: 'c1', riderId: 'rider-001', date: DateTime(2026, 6, 1), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p2', contractId: 'c1', riderId: 'rider-001', date: DateTime(2026, 6, 2), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p3', contractId: 'c1', riderId: 'rider-001', date: DateTime(2026, 6, 3), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p4', contractId: 'c1', riderId: 'rider-001', date: DateTime(2026, 6, 5), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p5', contractId: 'c1', riderId: 'rider-001', date: DateTime(2026, 6, 6), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p6', contractId: 'c1', riderId: 'rider-001', date: DateTime(2026, 6, 7), amountPaid: 2000, targetAmount: 4000, status: PaymentStatus.paid, isPartial: true),
    Payment(id: 'p7', contractId: 'c2', riderId: 'rider-002', date: DateTime(2026, 6, 1), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p8', contractId: 'c2', riderId: 'rider-002', date: DateTime(2026, 6, 2), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p9', contractId: 'c2', riderId: 'rider-002', date: DateTime(2026, 6, 3), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p10', contractId: 'c2', riderId: 'rider-002', date: DateTime(2026, 6, 4), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p11', contractId: 'c2', riderId: 'rider-002', date: DateTime(2026, 6, 5), amountPaid: 2000, targetAmount: 4000, status: PaymentStatus.paid, isPartial: true),
    Payment(id: 'p12', contractId: 'c3', riderId: 'rider-003', date: DateTime(2026, 6, 1), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.paid),
    Payment(id: 'p13', contractId: 'c3', riderId: 'rider-003', date: DateTime(2026, 6, 8), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.missed),
    Payment(id: 'p14', contractId: 'c3', riderId: 'rider-003', date: DateTime(2026, 6, 9), amountPaid: 4000, targetAmount: 4000, status: PaymentStatus.missed),
  ];

  List<Payment> paymentsForRider(String riderId) =>
      state.payments.where((p) => p.riderId == riderId).toList();

  double totalPaidForRider(String riderId) => _totalPaidForRider(state.payments, riderId);

  void addPayment(Payment payment) {
    state = state.copyWith(payments: [payment, ...state.payments]);
  }

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

final perRiderPaymentProvider = Provider.family<List<Payment>, String>((ref, riderId) {
  final payments = ref.watch(paymentProvider).payments;
  return payments.where((p) => p.riderId == riderId).toList();
});

final riderTotalPaidProvider = Provider.family<double, String>((ref, riderId) {
  final payments = ref.watch(paymentProvider).payments;
  return _totalPaidForRider(payments, riderId);
});
