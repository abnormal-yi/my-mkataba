import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/features/splash/splash_screen.dart';
import 'package:my_mkataba/features/login/login_screen.dart';
import 'package:my_mkataba/features/rider/rider_dashboard.dart';
import 'package:my_mkataba/features/rider/rider_payment_tracker.dart';
import 'package:my_mkataba/features/rider/rider_contracts.dart';
import 'package:my_mkataba/features/rider/rider_notifications.dart';
import 'package:my_mkataba/features/rider/rider_profile.dart';
import 'package:my_mkataba/features/owner/owner_dashboard.dart';
import 'package:my_mkataba/features/owner/owner_rider_detail.dart';
import 'package:my_mkataba/features/owner/owner_create_contract.dart';
import 'package:my_mkataba/features/owner/owner_income_gps.dart';
import 'package:my_mkataba/features/owner/owner_notifications.dart';
import 'package:my_mkataba/features/admin/admin_dashboard.dart';
import 'package:my_mkataba/features/admin/admin_users.dart';
import 'package:my_mkataba/features/admin/admin_reports.dart';
import 'package:my_mkataba/features/admin/admin_notifications.dart';
import 'package:my_mkataba/features/blocked/blocked_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login/:role', builder: (_, s) => LoginScreen(role: s.pathParameters['role']!)),
    GoRoute(path: '/rider', builder: (_, __) => const RiderDashboard()),
    GoRoute(path: '/rider/dashboard', redirect: (_, __) => '/rider'),
    GoRoute(path: '/rider/payments', builder: (_, __) => const RiderPaymentTracker()),
    GoRoute(path: '/rider/contracts', builder: (_, __) => const RiderContracts()),
    GoRoute(path: '/rider/notifications', builder: (_, __) => const RiderNotifications()),
    GoRoute(path: '/rider/profile', builder: (_, __) => const RiderProfile()),
    GoRoute(path: '/owner', builder: (_, __) => const OwnerDashboard()),
    GoRoute(path: '/owner/dashboard', redirect: (_, __) => '/owner'),
    GoRoute(path: '/owner/rider-detail/:riderId/:riderName/:plate/:balance/:blocked',
        builder: (_, s) => OwnerRiderDetail(
          riderId: s.pathParameters['riderId']!,
          riderName: Uri.decodeComponent(s.pathParameters['riderName']!),
          vehiclePlate: Uri.decodeComponent(s.pathParameters['plate']!),
          balanceRemaining: double.tryParse(s.pathParameters['balance'] ?? '0') ?? 0,
          isBlocked: s.pathParameters['blocked'] == '1',
        )),
    GoRoute(path: '/owner/create-contract', builder: (_, __) => const OwnerCreateContract()),
    GoRoute(path: '/owner/income', builder: (_, __) => const OwnerIncomeGps()),
    GoRoute(path: '/owner/notifications', builder: (_, __) => const OwnerNotifications()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
    GoRoute(path: '/admin/dashboard', redirect: (_, __) => '/admin'),
    GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsers()),
    GoRoute(path: '/admin/reports', builder: (_, __) => const AdminReports()),
    GoRoute(path: '/admin/notifications', builder: (_, __) => const AdminNotifications()),
    GoRoute(path: '/blocked', builder: (_, __) => const BlockedScreen()),
  ],
);

class MyMkatabaApp extends StatelessWidget {
  const MyMkatabaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Mkataba',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      routerConfig: router,
    );
  }
}
