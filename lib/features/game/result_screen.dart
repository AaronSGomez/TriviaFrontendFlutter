import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../domain/models/game_result.dart';
import '../../domain/repositories/game_repository.dart';
import '../dashboard/providers/leaderboard_provider.dart';

final resultProvider = FutureProvider.family<GameResult, String>((ref, sessionId) async {
  return ref.watch(gameRepositoryProvider).finishSession(sessionId);
});

class ResultScreen extends ConsumerWidget {
  final String sessionId;

  const ResultScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(sessionId));
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.primaryGradient,
        child: SafeArea(
          child: resultAsync.when(
            data: (result) {
              int? rank;
              leaderboardAsync.whenData((players) {
                final sorted = List.of(players)..sort((a, b) => b.score.compareTo(a.score));
                final index = sorted.indexWhere((p) => p.id == sessionId);
                if (index != -1) rank = index + 1;
              });

              Widget graphicWidget;
              String messageText;

              if (rank == 1) {
                graphicWidget = _buildTrophy(Colors.amber, '1');
                messageText = '¡Enhorabuena, eres el número 1!';
              } else if (rank == 2) {
                graphicWidget = _buildTrophy(Colors.grey.shade300, '2');
                messageText = '¡Excelente, segundo lugar!';
              } else if (rank == 3) {
                graphicWidget = _buildTrophy(const Color(0xFFCD7F32), '3');
                messageText = '¡Tercer lugar, muy bien!';
              } else {
                graphicWidget = _buildRankCircle(rank, result.isPassed);
                if (result.grade >= 5.0) {
                  messageText = '¡Enhorabuena, has aprobado!';
                } else {
                  messageText = 'Ánimo compañero, inténtalo otra vez';
                }
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(tag: 'logo', child: graphicWidget),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      messageText,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
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

  Widget _buildTrophy(Color color, String rankText) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.emoji_events, size: 150, color: color),
        Positioned(
          top: 30,
          child: Text(
            rankText,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRankCircle(int? rank, bool isPassed) {
    if (rank == null) {
      return Icon(
        isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
        size: 150,
        color: isPassed ? AppTheme.successColor : AppTheme.errorColor,
      );
    }
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceColor,
        border: Border.all(color: isPassed ? AppTheme.successColor : AppTheme.errorColor, width: 4),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Posición', style: TextStyle(fontSize: 16, color: Colors.white70)),
          Text(
            '#$rank',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
