import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/repositories/game_repository.dart';
import '../../../domain/repositories/auth_repository.dart';

final leaderboardProvider = FutureProvider.autoDispose<List<GameSession>>((ref) async {
  final leaderboard = await ref.watch(gameRepositoryProvider).getWeeklyLeaderboard();

  try {
    final players = await ref.watch(authRepositoryProvider).getRanking();
    final playerMap = {for (var p in players) p.id: p.name};

    final enriched = leaderboard.map((session) {
      if (playerMap.containsKey(session.playerId)) {
        return session.copyWith(playerName: playerMap[session.playerId]);
      }
      return session;
    }).toList();

    enriched.sort((a, b) {
      final bySubject = a.subject.toLowerCase().compareTo(b.subject.toLowerCase());
      if (bySubject != 0) return bySubject;

      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;

      final aDate = a.finishedAt ?? a.startedAt;
      final bDate = b.finishedAt ?? b.startedAt;
      return bDate.compareTo(aDate);
    });

    return enriched;
  } catch (e) {
    leaderboard.sort((a, b) {
      final bySubject = a.subject.toLowerCase().compareTo(b.subject.toLowerCase());
      if (bySubject != 0) return bySubject;

      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;

      final aDate = a.finishedAt ?? a.startedAt;
      final bDate = b.finishedAt ?? b.startedAt;
      return bDate.compareTo(aDate);
    });

    return leaderboard;
  }
});
