import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../domain/repositories/game_repository.dart';
import '../../auth/auth_controller.dart';

class PlayTab extends ConsumerStatefulWidget {
  const PlayTab({super.key});

  @override
  ConsumerState<PlayTab> createState() => _PlayTabState();
}

class _PlayTabState extends ConsumerState<PlayTab> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubject; // Nuevo dropdown state

  static const _subjects = [
    'Desarrollo de interfaces',
    'Acceso a datos',
    'Fundamentos de computación',
    'Entornos de desarrollo',
    'Itp 2',
    'Programación de servicios y procesos',
    'Programación multimedia y dispositivos  móviles',
    'Sistemas de gestión empresarial',
    'Sostenibilidad',
    'Digitalización',
    'Ingles',
  ];

  Future<void> _startGame() async {
    if (!_formKey.currentState!.validate()) return;

    final player = ref.read(authControllerProvider).player;
    if (player == null) return;

    setState(() => _isLoading = true);
    try {
      final session = await ref
          .read(gameRepositoryProvider)
          .startSession(player.id, _selectedSubject!, 3); // Hardcoded to 30
      if (mounted) {
        context.go('/game', extra: session.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al iniciar: $e'), backgroundColor: AppTheme.errorColor));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_esports, size: 100, color: AppTheme.primaryColor),
            const SizedBox(height: 32),
            Text(
              'Prueba de Nivel (30 Preguntas)',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Categoría (Obligatoria)', prefixIcon: Icon(Icons.category)),
              items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _selectedSubject = v),
              validator: (v) => v == null || v.isEmpty ? 'Debes seleccionar una categoría' : null,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startGame,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Empezar Partida', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
