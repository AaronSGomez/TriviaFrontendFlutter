import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/leaderboard_provider.dart';
import '../../../core/theme.dart';
import '../../auth/auth_controller.dart';
import '../../../domain/models/game_session.dart';

class LeaderboardTab extends ConsumerWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentPlayerId = ref.watch(authControllerProvider).player?.id;

    return leaderboardAsync.when(
      data: (players) {
        if (players.isEmpty) {
          return const Center(child: Text('No hay partidas en los ultimos 7 dias.'));
        }

        final groupedBySubject = <String, List<GameSession>>{};
        for (final session in players) {
          groupedBySubject.putIfAbsent(session.subject, () => []).add(session);
        }

        final subjects = groupedBySubject.keys.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        return RefreshIndicator(
          onRefresh: () => ref.refresh(leaderboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Text(
                  'Ranking por asignaturas (ultimos 7 dias) · Top 10 por asignatura',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              ...subjects.map((subject) {
                final subjectSessions = groupedBySubject[subject]!;
                final topTen = subjectSessions.take(10).toList();

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      title: Text(
                        subject,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      subtitle: Text('Mostrar top ${topTen.length}'),
                      children: topTen.asMap().entries.map((entry) {
                        final localIndex = entry.key;
                        final session = entry.value;
                        final isMe = session.playerId == currentPlayerId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isMe ? AppTheme.primaryColor.withValues(alpha: 0.2) : Colors.black12,
                            borderRadius: BorderRadius.circular(14),
                            border: isMe ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMe ? AppTheme.primaryColor : Colors.grey.shade700,
                              child: Text(
                                '${localIndex + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              isMe ? 'Tú' : (session.playerName ?? 'Jugador'),
                              style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
                            ),
                            subtitle: Text('Estado: ${session.status}'),
                            trailing: Text(
                              '${session.score} pts',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text('Error: $e'),
            ElevatedButton(onPressed: () => ref.refresh(leaderboardProvider), child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
