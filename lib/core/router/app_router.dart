import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// Placeholder screens for routing setup
import '../../features/auth/welcome_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/game/game_screen.dart';
import '../../features/game/result_screen.dart';
import '../../features/game/review_failed_questions_screen.dart';

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
        if (sessionId == null || sessionId.isEmpty) {
          return const _SessionInterruptedScreen();
        }
        return GameScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/results',
      builder: (context, state) {
        final sessionId = state.extra as String?;
        if (sessionId == null || sessionId.isEmpty) {
          return const _SessionInterruptedScreen();
        }
        return ResultScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/review-failed',
      builder: (context, state) {
        final sessionId = state.extra as String?;
        if (sessionId == null || sessionId.isEmpty) {
          return const _SessionInterruptedScreen();
        }
        return ReviewFailedQuestionsScreen(sessionId: sessionId);
      },
    ),
  ],
);

class _SessionInterruptedScreen extends StatelessWidget {
  const _SessionInterruptedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Se produjo un error de sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Por seguridad, hemos detenido el test y te llevaremos al dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Ir al dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
