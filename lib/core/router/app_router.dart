import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// Placeholder screens for routing setup
import '../../features/auth/welcome_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/game/game_screen.dart';
import '../../features/game/result_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/game',
      builder: (context, state) {
        final sessionId = state.extra as String?;
        return GameScreen(sessionId: sessionId ?? '');
      },
    ),
    GoRoute(
      path: '/results',
      builder: (context, state) {
        final sessionId = state.extra as String?;
        return ResultScreen(sessionId: sessionId ?? '');
      },
    ),
  ],
);
