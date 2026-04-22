import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/player.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/providers.dart';
import '../../core/security/jwt_utils.dart';

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController extends ChangeNotifier {
  final Ref ref;
  final GoogleSignIn _googleSignIn;
  final Future<void> _googleInitFuture;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _webAuthEventsSub;

  Player? player;
  bool isLoading = true;
  String? error;

  static const _playerIdKey = 'player_id';
  static const _playerNameKey = 'player_name';
  static const _playerMailKey = 'player_mail';
  static const _tokenKey = 'jwt_token';

  AuthController(this.ref) : _googleSignIn = GoogleSignIn.instance, _googleInitFuture = _initializeGoogleSignIn() {
    unawaited(_googleInitFuture);
    if (kIsWeb) {
      _webAuthEventsSub = _googleSignIn.authenticationEvents.listen(
        (event) {
          debugPrint('[GoogleAuth] Event received: $event');
          if (event is GoogleSignInAuthenticationEventSignIn) {
            debugPrint('[GoogleAuth] Web auth event: User signed in');
          }
        },
        onError: (Object e) {
          debugPrint('[GoogleAuth] Event listener error: $e');
          error = 'Error en Google Auth: $e';
          isLoading = false;
          notifyListeners();
        },
      );
    }
    _loadPlayer();
  }

  static Future<void> _initializeGoogleSignIn() async {
    try {
      if (kIsWeb) {
        debugPrint('[GoogleAuth] Initializing GoogleSignIn for Web');
        await GoogleSignIn.instance.initialize(clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID']);
        debugPrint('[GoogleAuth] GoogleSignIn Web initialized successfully');
      } else if (defaultTargetPlatform != TargetPlatform.windows) {
        debugPrint('[GoogleAuth] Initializing GoogleSignIn for mobile');
        await GoogleSignIn.instance.initialize(serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID']);
        debugPrint('[GoogleAuth] GoogleSignIn mobile initialized successfully');
      } else {
        debugPrint('[GoogleAuth] Windows platform detected - skipping Google init');
      }
    } catch (e) {
      debugPrint('[GoogleAuth] Initialization error: $e');
    }
  }

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
      prefs.remove(_playerIdKey);
      prefs.remove(_playerNameKey);
      prefs.remove(_playerMailKey);
      prefs.remove(_tokenKey);
      player = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      throw const AuthException(
        'google-not-supported-windows',
        'Acceso con Google no esta disponible en la app nativa de Windows. Usa la version web.',
      );
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        debugPrint('[GoogleAuth] Web: Using Firebase signInWithPopup...');
        await _authenticateWebWithFirebasePopup();
      } else {
        debugPrint('[GoogleAuth] Mobile: Waiting for Google initialization...');
        await _googleInitFuture;

        debugPrint('[GoogleAuth] Mobile: Starting authentication...');
        final googleUser = await _googleSignIn.authenticate(scopeHint: const ['email', 'profile']);

        if (googleUser == null) {
          throw const AuthException('google-canceled', 'Inicio de sesión con Google cancelado.');
        }

        await _authenticateAndRegisterWithFirebase(googleUser);
      }
    } on MissingPluginException catch (_) {
      final wrapped = const AuthException(
        'google-not-supported-platform',
        'Tu plataforma actual no soporta Google Sign-In nativo. Usa la version web.',
      );
      error = wrapped.toString();
      throw wrapped;
    } catch (e) {
      debugPrint('[GoogleAuth] Error: $e');
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Web-specific authentication using Firebase's signInWithPopup.
  /// This is the proper web-native approach recommended by Google.
  Future<void> _authenticateWebWithFirebasePopup() async {
    try {
      final firebaseAuth = FirebaseAuth.instance;

      debugPrint('[GoogleAuth] Step 1: Initiating Firebase popup sign-in...');
      final userCredential = await firebaseAuth.signInWithPopup(GoogleAuthProvider());

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('firebase-user-missing', 'No se pudo obtener el usuario de Firebase.');
      }

      debugPrint('[GoogleAuth] Step 2: Firebase user authenticated: ${user.email}');

      debugPrint('[GoogleAuth] Step 3: Getting Firebase ID token...');
      final firebaseIdToken = await user.getIdToken(true);

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw const AuthException('firebase-token-missing', 'Firebase no devolvio un token valido.');
      }

      debugPrint('[GoogleAuth] Step 4: Sending Firebase token to backend...');
      await _completeBackendGoogleLogin(firebaseIdToken);
    } on FirebaseAuthException catch (e) {
      String friendlyMessage = 'Error en Google Sign-In: ${e.message}';

      if (e.code == 'popup-closed-by-user') {
        throw const AuthException('google-canceled', 'Inicio de sesión con Google cancelado.');
      } else if (e.code == 'network-request-failed') {
        friendlyMessage = 'Error de conexión. Verifica tu internet y vuelve a intentar.';
      } else if (e.code == 'credential-already-in-use') {
        friendlyMessage = 'Esta cuenta ya está siendo usada. Cierra sesión primero.';
      }

      throw AuthException('firebase-error', friendlyMessage);
    }
  }

  /// Authenticates with Firebase using Google credentials and completes backend login.
  /// A. Obtiene credenciales de Google (idToken/accessToken)
  /// B. Crea la credencial para Firebase
  /// C. Registra en Firebase (esto vincula el usuario a Firebase)
  /// D. Obtiene el ID token de Firebase
  /// E. Envía el Firebase ID token al backend de Java para validación
  Future<void> _authenticateAndRegisterWithFirebase(GoogleSignInAccount googleUser) async {
    debugPrint('[GoogleAuth] Step A: Obtaining Google credentials...');
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw const AuthException('google-token-missing', 'Google no devolvio token valido. Intentalo de nuevo.');
    }

    debugPrint('[GoogleAuth] Step B: Creating Firebase credential...');
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    debugPrint('[GoogleAuth] Step C: Signing in with Firebase...');
    final firebaseAuth = FirebaseAuth.instance;
    UserCredential userCredential;
    try {
      userCredential = await firebaseAuth.signInWithCredential(credential);
      debugPrint('[GoogleAuth] Firebase user linked: ${userCredential.user?.email}');
    } catch (e) {
      throw AuthException('firebase-link-failed', 'No se pudo vincular a Firebase: $e');
    }

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw const AuthException('firebase-user-missing', 'No se pudo obtener el usuario de Firebase.');
    }

    debugPrint('[GoogleAuth] Step D: Getting Firebase ID token...');
    final firebaseIdToken = await firebaseUser.getIdToken(true);
    if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
      throw const AuthException('firebase-token-missing', 'Firebase no devolvio un token valido.');
    }

    debugPrint('[GoogleAuth] Step E: Sending Firebase token to backend...');
    await _completeBackendGoogleLogin(firebaseIdToken, googleIdToken: idToken);
  }

  Future<void> _saveSession(dynamic prefs, AuthResult result) async {
    await prefs.setString(_playerIdKey, result.player.id);
    await prefs.setString(_playerNameKey, result.player.name);
    await prefs.setString(_playerMailKey, result.player.mail);
    await prefs.setString(_tokenKey, result.token);
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    await prefs.clear();
    player = null;
    notifyListeners();
  }

  Future<void> _completeBackendGoogleLogin(String firebaseIdToken, {String? googleIdToken}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final repository = ref.read(authRepositoryProvider);
      final prefs = ref.read(sharedPreferencesProvider);

      final result = await repository.loginWithGoogle(firebaseIdToken, googleIdToken: googleIdToken);
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

  @override
  void dispose() {
    unawaited(_webAuthEventsSub?.cancel());
    super.dispose();
  }
}
