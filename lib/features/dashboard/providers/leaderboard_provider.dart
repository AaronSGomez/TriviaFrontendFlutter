import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/repositories/game_repository.dart';
import '../../../domain/repositories/auth_repository.dart';

final leaderboardProvider = FutureProvider.autoDispose<List<GameSession>>((ref) async {
  final leaderboard = await ref.watch(gameRepositoryProvider).getLeaderboard();

  try {
    final players = await ref.watch(authRepositoryProvider).getRanking();
    final playerMap = {for (var p in players) p.id: p.name};

    return leaderboard.map((session) {
      if (playerMap.containsKey(session.playerId)) {
        return session.copyWith(playerName: playerMap[session.playerId]);
      }
      return session;
    }).toList();
  } catch (e) {
    return leaderboard;
  }
});
