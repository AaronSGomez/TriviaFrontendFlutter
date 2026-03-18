import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- 1. Importaciones de Firebase ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

import 'core/theme.dart';
import 'core/router/app_router.dart';
import 'core/providers.dart';

void main() async {
  // Aseguramos el binding de Flutter (ya lo tenías)
  WidgetsFlutterBinding.ensureInitialized();

  // Cargamos entorno y preferencias
  await dotenv.load(fileName: ".env");
  final sharedPreferences = await SharedPreferences.getInstance();

  // --- 2. Inicializamos Firebase ---
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
      child: const TriviaApp(),
    ),
  );
}

class TriviaApp extends StatelessWidget {
  const TriviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DAMTrivia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
