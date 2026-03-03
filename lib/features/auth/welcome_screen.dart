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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mailController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authControllerProvider.notifier).login(_nameController.text, _mailController.text);
        if (mounted) context.go('/dashboard');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  if (authState.error != null) {
                    return Text('Error al cargar: ${authState.error}', style: const TextStyle(color: Colors.white));
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
                        'Test de Estudios DAM 2026',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Text(
                                    'Registro',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre de usuario',
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _mailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Correo electrónico',
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _submit,
                                      child: const Text('Comenzar', style: TextStyle(fontSize: 18)),
                                    ),
                                  ),
                                ],
                              ),
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
