import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../domain/models/game_result.dart';
import '../../domain/repositories/game_repository.dart';

final resultProvider = FutureProvider.family<GameResult, String>((ref, sessionId) async {
  return ref.watch(gameRepositoryProvider).finishSession(sessionId);
});

class ResultScreen extends ConsumerWidget {
  final String sessionId;

  const ResultScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(sessionId));

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.primaryGradient,
        child: SafeArea(
          child: resultAsync.when(
            data: (result) {
              final color = result.isPassed ? AppTheme.successColor : AppTheme.errorColor;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Icon(
                      result.isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                      size: 150,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    result.isPassed ? '¡Aprobado!' : 'Suspenso',
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: AppTheme.surfaceColor,
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildStatRow('Nota (0-10)', result.grade.toStringAsFixed(1)),
                          const Divider(height: 32),
                          _buildStatRow('Ranking Pts', '+${result.score}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text(
                      'Volver al Dashboard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (e, st) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  Text('Error al obtener resultados', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ElevatedButton(onPressed: () => context.go('/dashboard'), child: const Text('Volver al Dashboard')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
