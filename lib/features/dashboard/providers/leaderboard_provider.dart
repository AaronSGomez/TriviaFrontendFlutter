import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/repositories/game_repository.dart';

final leaderboardProvider = FutureProvider.autoDispose<List<GameSession>>((ref) async {
  return ref.watch(gameRepositoryProvider).getLeaderboard();
});
