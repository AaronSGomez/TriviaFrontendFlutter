import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/player.dart';
import '../../../domain/repositories/auth_repository.dart';

final leaderboardProvider = FutureProvider.autoDispose<List<Player>>((ref) async {
  return ref.watch(authRepositoryProvider).getRanking();
});
