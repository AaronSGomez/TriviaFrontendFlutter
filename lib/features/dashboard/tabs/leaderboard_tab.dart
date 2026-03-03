import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/leaderboard_provider.dart';
import '../../../core/theme.dart';
import '../../auth/auth_controller.dart';

class LeaderboardTab extends ConsumerWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentPlayerId = ref.watch(authControllerProvider).player?.id;

    return leaderboardAsync.when(
      data: (players) {
        if (players.isEmpty) {
          return const Center(child: Text('No hay jugadores aún.'));
        }

        // Optional: Sort by score if API doesn't do it.
        // players.sort((a,b) => b.totalScore.compareTo(a.totalScore));

        return RefreshIndicator(
          onRefresh: () => ref.refresh(leaderboardProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final session = players[index];
              final isMe = session.playerId == currentPlayerId;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isMe ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isMe ? AppTheme.primaryColor : Colors.grey.shade700,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    isMe ? 'Tú (${session.subject})' : '${session.playerName ?? 'Jugador'} (${session.subject})',
                    style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
                  ),
                  subtitle: Text('Estado: ${session.status}'),
                  trailing: Text(
                    '${session.score} pts',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                  ),
                ),
              );
            },
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
