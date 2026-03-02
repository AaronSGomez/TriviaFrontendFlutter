import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/player.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/providers.dart';

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

  void _loadPlayer() {
    final prefs = ref.read(sharedPreferencesProvider);
    final id = prefs.getString(_playerIdKey);
    final name = prefs.getString(_playerNameKey);
    final mail = prefs.getString(_playerMailKey);

    if (id != null && name != null && mail != null) {
      player = Player(id: id, name: name, mail: mail);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String name, String mail) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = ref.read(authRepositoryProvider);
      final prefs = ref.read(sharedPreferencesProvider);

      final newPlayer = await repository.registerOrLogin(name, mail);
      await prefs.setString(_playerIdKey, newPlayer.id);
      await prefs.setString(_playerNameKey, newPlayer.name);
      await prefs.setString(_playerMailKey, newPlayer.mail);

      player = newPlayer;
    } catch (e) {
      error = e.toString();
      throw e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.clear();
    player = null;
    notifyListeners();
  }
}
