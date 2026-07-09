import 'package:riverpod/riverpod.dart';
import 'package:my_mkataba/models/app_models.dart';
import 'package:my_mkataba/core/api_client.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => NotificationNotifier());

class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({this.notifications = const [], this.isLoading = false, this.error});

  NotificationState copyWith({List<AppNotification>? notifications, bool? isLoading, String? error}) =>
      NotificationState(notifications: notifications ?? this.notifications, isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState(
    notifications: [
      AppNotification(id: 'n1', userId: 'rider-001', title: 'Payment Reminder', message: 'TSh 4,000 payment is due today.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)), type: NotificationType.paymentReminder),
      AppNotification(id: 'n2', userId: 'rider-001', title: 'Missed Payment', message: 'You missed the payment on June 10. Please pay soon.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)), type: NotificationType.missedPayment),
      AppNotification(id: 'n3', userId: 'rider-001', title: 'Contract Expiring', message: 'Your contract ends in 14 days. Contact your owner.',
          timestamp: DateTime.now().subtract(const Duration(days: 5)), type: NotificationType.contractExpiry),
      AppNotification(id: 'n4', userId: 'rider-001', title: 'Payment Received', message: 'TSh 4,000 payment confirmed via M-Pesa.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)), type: NotificationType.general, isRead: true),
      AppNotification(id: 'n5', userId: 'rider-001', title: 'Weekly Summary', message: 'You paid 5/7 days this week. TSh 8,000 missed.',
          timestamp: DateTime.now().subtract(const Duration(days: 7)), type: NotificationType.general, isRead: true),
    ],
  ));

  void addNotification(AppNotification notification) {
    state = state.copyWith(notifications: [notification, ...state.notifications]);
  }

  Future<void> fetchByUser(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = buildApiClient();
      final res = await dio.get('/notifications/$userId');
      state = NotificationState(notifications: (res.data as List).map((j) => AppNotification.fromJson(j)).toList());
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}
