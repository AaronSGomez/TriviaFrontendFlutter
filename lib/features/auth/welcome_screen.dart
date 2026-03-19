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
  final _passwordController = TextEditingController();

  bool _isRegisterMode = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final controller = ref.read(authControllerProvider.notifier);
      if (_isRegisterMode) {
        await controller.register(_nameController.text.trim(), _mailController.text.trim(), _passwordController.text);
      } else {
        await controller.login(_mailController.text.trim(), _passwordController.text);
      }
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

    if (lower.contains('contraseña o correo incorrectos') ||
        lower.contains('invalid-credentials') ||
        lower.contains('401') ||
        lower.contains('unauthorized') ||
        lower.contains('formatexception')) {
      return 'Contraseña incorrecta. Verifica tus credenciales e inténtalo de nuevo.';
    }

    if (lower.contains('409') || lower.contains('conflict')) {
      return 'Ya existe una cuenta con ese correo.';
    }

    if (lower.contains('token caducado') || lower.contains('no hay sesión activa')) {
      return 'Tu sesión ha expirado. Inicia sesión o regístrate para continuar.';
    }

    return raw;
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Text(
                                    _isRegisterMode ? 'Registro' : 'Iniciar sesión',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 24),
                                  // Name field — only in register mode
                                  if (_isRegisterMode) ...[
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nombre de usuario',
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  TextFormField(
                                    controller: _mailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Correo electrónico',
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Requerido';
                                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegex.hasMatch(v)) return 'Formato de correo no válido';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña',
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Requerido';
                                      if (_isRegisterMode && v.length < 6) return 'Mínimo 6 caracteres';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _submit,
                                      child: Text(
                                        _isRegisterMode ? 'Registrarse' : 'Entrar',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _isRegisterMode = !_isRegisterMode;
                                      _formKey.currentState?.reset();
                                    }),
                                    child: Text(
                                      _isRegisterMode
                                          ? '¿Ya tienes cuenta? Inicia sesión'
                                          : '¿No tienes cuenta? Regístrate',
                                      style: TextStyle(color: AppTheme.primaryColor),
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
