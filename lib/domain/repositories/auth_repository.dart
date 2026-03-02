import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/player.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Player> registerOrLogin(String name, String mail) async {
    try {
      final response = await _dio.post('/api/v1/players', data: {'name': name, 'mail': mail});
      return Player.fromJson(response.data);
    } catch (e) {
      // In a real scenario we'd check if status code is 409 (conflict) or similar,
      // and then GET the player if they already exist, or the API might return the existing.
      // Assuming the API returns the created/existing player directly.
      rethrow;
    }
  }

  Future<List<Player>> getRanking() async {
    final response = await _dio.get('/api/v1/players');
    return (response.data as List).map((x) => Player.fromJson(x)).toList();
  }
}
