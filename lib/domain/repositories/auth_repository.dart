import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/config.dart';
import '../models/player.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Registers a new player.
  /// Uses /api/auth/register/admin if the app was compiled with IS_ADMIN=true,
  /// otherwise uses /api/auth/register.
  Future<AuthResult> register(String name, String mail, String password) async {
    final endpoint = kIsAdmin ? '/api/auth/register/admin' : '/api/auth/register';
    final response = await _dio.post(endpoint, data: {'name': name, 'mail': mail, 'password': password});
    return AuthResult.fromJson(response.data);
  }

  /// Logs in an existing player and returns a JWT token + player data.
  Future<AuthResult> login(String mail, String password) async {
    final response = await _dio.post('/api/auth/login', data: {'mail': mail, 'password': password});
    return AuthResult.fromJson(response.data);
  }

  Future<List<Player>> getRanking() async {
    final response = await _dio.get('/api/v1/players');
    return (response.data as List).map((x) => Player.fromJson(x)).toList();
  }
}

/// Holds the result from register/login: a JWT token and the player data.
class AuthResult {
  final String token;
  final Player player;

  AuthResult({required this.token, required this.player});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('token')) {
      throw Exception('Missing token in auth response');
    }

    final token = json['token'] as String;

    // 1. Try to parse flat structure (expected from register)
    if (json.containsKey('id') && json.containsKey('name') && json.containsKey('mail')) {
      return AuthResult(token: token, player: Player.fromJson(json));
    }

    // 2. Try nested player or user objects instead
    for (final key in ['player', 'user']) {
      if (json.containsKey(key) && json[key] is Map<String, dynamic>) {
        final nested = json[key] as Map<String, dynamic>;
        if (nested.containsKey('id') && nested.containsKey('name') && nested.containsKey('mail')) {
          return AuthResult(token: token, player: Player.fromJson(nested));
        }
      }
    }

    // 3. Fallback: Parse the JWT token itself if player info is absent from response (like in login currently)
    String decodedMail = 'unknown@example.com';
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        final payloadStr = parts[1];
        final normalized = base64Url.normalize(payloadStr);
        final payloadMap = jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
        if (payloadMap.containsKey('sub')) {
          decodedMail = payloadMap['sub'] as String;
        } else if (payloadMap.containsKey('mail')) {
          decodedMail = payloadMap['mail'] as String;
        } else if (payloadMap.containsKey('email')) {
          decodedMail = payloadMap['email'] as String;
        }
      }
    } catch (_) {
      // Ignore decoding errors
    }

    final placeholderName = decodedMail.split('@').first;

    final player = Player(
      id: 'login_session', // We don't have the real ID from login right now
      name: placeholderName, // Extracted from mail
      mail: decodedMail,
    );

    return AuthResult(token: token, player: player);
  }
}
