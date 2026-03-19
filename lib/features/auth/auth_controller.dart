import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/player.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/providers.dart';
import '../../core/security/jwt_utils.dart';

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController extends ChangeNotifier {
  final Ref ref;

  Player? player;
  bool isLoading = true;
  String? error;

  AuthController(this.ref) {
    _loadPlayer();
  }

  static const _playerIdKey = 'player_id';
  static const _playerNameKey = 'player_name';
  static const _playerMailKey = 'player_mail';
  static const _tokenKey = 'jwt_token';

  void _loadPlayer() {
    final prefs = ref.read(sharedPreferencesProvider);
    final id = prefs.getString(_playerIdKey);
    final name = prefs.getString(_playerNameKey);
    final mail = prefs.getString(_playerMailKey);
    final token = prefs.getString(_tokenKey);

    final hasSessionData = id != null && name != null && mail != null;
    final hasValidToken = token != null && token.isNotEmpty && !isJwtExpired(token);

    if (hasSessionData && hasValidToken) {
      player = Player(id: id, name: name, mail: mail);
    } else {
      // Cleanup inconsistent or expired local session.
      prefs.remove(_playerIdKey);
      prefs.remove(_playerNameKey);
      prefs.remove(_playerMailKey);
      prefs.remove(_tokenKey);
      player = null;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> register(String name, String mail, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = ref.read(authRepositoryProvider);
      final prefs = ref.read(sharedPreferencesProvider);

      final result = await repository.register(name, mail, password);
      await _saveSession(prefs, result);
      player = result.player;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String mail, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = ref.read(authRepositoryProvider);
      final prefs = ref.read(sharedPreferencesProvider);

      final result = await repository.login(mail, password);
      await _saveSession(prefs, result);
      player = result.player;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession(dynamic prefs, AuthResult result) async {
    await prefs.setString(_playerIdKey, result.player.id);
    await prefs.setString(_playerNameKey, result.player.name);
    await prefs.setString(_playerMailKey, result.player.mail);
    await prefs.setString(_tokenKey, result.token);
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.clear();
    player = null;
    notifyListeners();
  }
}
