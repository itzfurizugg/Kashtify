import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screen/login_screen.dart';
import '../screen/register_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/siswa/home_screen.dart';
import '../screen/siswa/payment_screen.dart';
import '../screen/siswa/qris_screen.dart';
import '../screen/siswa/history_screen.dart';
import '../screen/siswa/money_screen.dart';
import '../screen/siswa/request_fund_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
    GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
    GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
    GoRoute(path: '/payment', builder: (c, s) => const PaymentScreen()),
    GoRoute(
      path: '/payment/qris',
      builder: (c, s) {
        final extra = s.extra as Map<String, dynamic>;
        return QRISScreen(
          iuranId: extra['iuranId'] as String,
          amount: extra['amount'] as num,
          title: extra['title'] as String,
        );
      },
    ),
    GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
    GoRoute(path: '/money', builder: (c, s) => const MoneyScreen()),
    GoRoute(
        path: '/request-fund', builder: (c, s) => const RequestFundScreen()),
  ],
);
