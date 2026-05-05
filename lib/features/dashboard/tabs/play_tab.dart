import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../domain/repositories/game_repository.dart';
import '../../auth/auth_controller.dart';
import '../providers/subjects_provider.dart';

class PlayTab extends ConsumerStatefulWidget {
  const PlayTab({super.key});

  @override
  ConsumerState<PlayTab> createState() => _PlayTabState();
}

class _PlayTabState extends ConsumerState<PlayTab> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubject; // Nuevo dropdown state

  Future<void> _startGame() async {
    if (!_formKey.currentState!.validate()) return;

    final player = ref.read(authControllerProvider).player;
    if (player == null) return;

    setState(() => _isLoading = true);
    try {
      final session = await ref
          .read(gameRepositoryProvider)
          .startSession(player.id, _selectedSubject!, 30); // Hardcoded to 30
      
      if (mounted) {
        if (session.sessionType == 'REVIEW') {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.secondaryColor),
                  SizedBox(width: 10),
                  Text('¡Sesión de Repaso!'),
                ],
              ),
              content: Text(
                'Vas a repasar las ${session.reviewQuestionCount ?? 0} preguntas que fallaste anteriormente.\n\n'
                'El test se completará con nuevas hasta llegar a las 30 preguntas, ¡mucha suerte!',
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('¡ENTENDIDO!', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ),
              ],
            ),
          );
        }
        
        if (mounted) {
          context.go('/game', extra: session.id);
        }
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
            const Image(
              image: AssetImage('lib/core/assets/damtrivia.png'),
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              'Prueba de Nivel (30 Preguntas)',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ref
                .watch(subjectsProvider)
                .when(
                  data: (subjects) {
                    if (subjects.isEmpty) {
                      return const Text('No hay preguntas disponibles todavía.');
                    }

                    // Si el sujeto seleccionado ya no está en la lista de sujetos, resetéalo
                    if (_selectedSubject != null && !subjects.any((s) => s.name == _selectedSubject)) {
                      _selectedSubject = null;
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Categoría (Obligatoria)',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: subjects.map((s) {
                        return DropdownMenuItem(
                          value: s.name,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(s.name, overflow: TextOverflow.ellipsis)),
                              Text(
                                '${s.count}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedSubject = v),
                      validator: (v) => v == null || v.isEmpty ? 'Debes seleccionar una categoría' : null,
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, st) => Text('Error cargando categorías: $e'),
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
