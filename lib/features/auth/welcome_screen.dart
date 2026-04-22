import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'auth_controller.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  void _continueWithGoogle() async {
    try {
      final controller = ref.read(authControllerProvider.notifier);
      await controller.signInWithGoogle();
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        final message = _friendlyError(e.toString());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor));
      }
    }
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();

    if (lower.contains('google no devolvio un token valido') ||
        lower.contains('google-token-missing') ||
        lower.contains('google-login-failed')) {
      return 'No se pudo completar el acceso con Google. Intentalo de nuevo.';
    }

    if (lower.contains('canceled') || lower.contains('interrupted') || lower.contains('uiunavailable')) {
      return 'No se pudo completar el acceso de Google en web. Revisa cookies de terceros y bloqueadores, o prueba en modo incognito.';
    }

    if (lower.contains('google-not-supported-windows') ||
        lower.contains('google-not-supported-platform') ||
        lower.contains('not available on this platform')) {
      return 'Google Sign-In no esta disponible en Windows nativo. Usa la version web.';
    }

    if (lower.contains('no se pudo validar la cuenta de google') || lower.contains('invalidgoogletokenexception')) {
      return 'La autenticacion de Google no fue valida. Vuelve a intentarlo.';
    }

    if (lower.contains('cancel')) {
      return 'Inicio de sesion cancelado.';
    }

    if (lower.contains('token caducado') || lower.contains('no hay sesion activa')) {
      return 'Tu sesion ha expirado. Inicia sesion con Google para continuar.';
    }

    return raw;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if ((previous?.player == null) && next.player != null && mounted) {
        context.go('/dashboard');
      }
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: AppTheme.primaryGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Builder(
                builder: (context) {
                  if (authState.isLoading) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }

                  final player = authState.player;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Hero(
                        tag: 'logo',
                        child: Image(
                          image: AssetImage('lib/core/assets/damtrivia.png'),
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Test-generator!! DAM',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 48),
                      if (player != null) ...[
                        Text(
                          '¡Hola de nuevo, ${player.name}!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/dashboard'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryColor,
                            ),
                            child: const Text(
                              'Jugar de Nuevo',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                          child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                        ),
                      ] else ...[
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          color: AppTheme.backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  'Acceso con Google',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Usa tu cuenta de Gmail para entrar. Guardaremos solo tu nombre y correo.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 28),
                                if (kIsWeb)
                                  const _GoogleWebButton()
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _continueWithGoogle,
                                      icon: const Icon(Icons.login),
                                      label: const Text('Continuar con Google', style: TextStyle(fontSize: 18)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleWebButton extends ConsumerWidget {
  const _GoogleWebButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final controller = ref.read(authControllerProvider.notifier);
          try {
            await controller.signInWithGoogle();
            if (context.mounted) {
              context.go('/dashboard');
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor));
            }
          }
        },
        icon: const Icon(Icons.login),
        label: const Text('Continuar con Google', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
