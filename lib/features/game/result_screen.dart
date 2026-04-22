import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../domain/models/game_result.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/models/game_session.dart';
import 'game_controller.dart';

final resultProvider = FutureProvider.family<GameResult, String>((ref, sessionId) async {
  return ref.watch(gameRepositoryProvider).finishSession(sessionId);
});

final weeklyLeaderboardProvider = FutureProvider.autoDispose<List<GameSession>>((ref) async {
  return ref.watch(gameRepositoryProvider).getWeeklyLeaderboard();
});

class ResultScreen extends ConsumerWidget {
  final String sessionId;

  const ResultScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(sessionId));
    final weeklyLeaderboardAsync = ref.watch(weeklyLeaderboardProvider);
    final gameController = ref.watch(gameControllerProvider(sessionId));

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.primaryGradient,
        child: SafeArea(
          child: resultAsync.when(
            data: (result) {
              int? weeklyRank;
              String? weeklySubject;
              weeklyLeaderboardAsync.whenData((sessions) {
                final currentSessionIndex = sessions.indexWhere((s) => s.id == sessionId);
                if (currentSessionIndex == -1) return;

                final currentSubject = sessions[currentSessionIndex].subject;
                weeklySubject = currentSubject;

                // Posición semanal dentro de la misma asignatura.
                final subjectSessions =
                    sessions.where((s) => s.subject.toLowerCase() == currentSubject.toLowerCase()).toList()
                      ..sort((a, b) => b.score.compareTo(a.score));

                final index = subjectSessions.indexWhere((s) => s.id == sessionId);
                if (index != -1) weeklyRank = index + 1;
              });

              Widget graphicWidget;
              String messageText;
              String? weeklyBadge;

              if (weeklyRank == 1) {
                graphicWidget = _buildTrophy(Colors.amber, '1');
                messageText = '¡Enhorabuena, eres el número 1 esta semana!';
                weeklyBadge = '🏆 Top 1 Semanal';
              } else if (weeklyRank == 2) {
                graphicWidget = _buildTrophy(Colors.grey.shade300, '2');
                messageText = '¡Excelente, segundo lugar esta semana!';
                weeklyBadge = '🥈 Top 2 Semanal';
              } else if (weeklyRank == 3) {
                graphicWidget = _buildTrophy(const Color(0xFFCD7F32), '3');
                messageText = '¡Tercer lugar esta semana, muy bien!';
                weeklyBadge = '🥉 Top 3 Semanal';
              } else {
                graphicWidget = _buildRankCircle(weeklyRank, result.isPassed);
                if (result.grade >= 5.0) {
                  messageText = '¡Enhorabuena, has aprobado!';
                } else {
                  messageText = 'Ánimo compañero, inténtalo otra vez';
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
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
                    if (weeklyBadge != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.secondaryColor),
                        ),
                        child: Text(
                          weeklyBadge,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
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
                            const Divider(height: 32),
                            _buildStatRow('Posición Semanal (${weeklySubject ?? 'asignatura'})', '#${weeklyRank ?? '?'}'),
                          ],
                        ),
                      ),
                    ),
                    if (gameController.failedQuestions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.push('/review-failed', extra: sessionId),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text('Repasar preguntas falladas (${gameController.failedQuestions.length})'),
                          ),
                        ),
                      ),
                    ],
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
                ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 320;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: TextStyle(fontSize: isCompact ? 16 : 20),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 2,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: isCompact ? 20 : 24, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
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
