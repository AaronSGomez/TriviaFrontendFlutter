import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/config.dart';
import '../../../domain/repositories/question_repository.dart';

class AddQuestionTab extends ConsumerStatefulWidget {
  const AddQuestionTab({super.key});

  @override
  ConsumerState<AddQuestionTab> createState() => _AddQuestionTabState();
}

class _AddQuestionTabState extends ConsumerState<AddQuestionTab> {
  final _formKey = GlobalKey<FormState>();
  final _statementController = TextEditingController();
  String? _selectedSubject;
  final _topicController = TextEditingController();
  final _optAController = TextEditingController();
  final _optBController = TextEditingController();
  final _optCController = TextEditingController();
  final _optDController = TextEditingController();
  final _explanationController = TextEditingController();

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

  int _correctIndex = 1;
  String _difficulty = 'Medio';
  bool _isActive = true;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final correctOptionString = _correctIndex == 1
          ? 'optionA'
          : _correctIndex == 2
          ? 'optionB'
          : _correctIndex == 3
          ? 'optionC'
          : 'optionD';

      await ref
          .read(questionRepositoryProvider)
          .createQuestion(
            statement: _statementController.text,
            subject: _selectedSubject!,
            topic: _topicController.text,
            optionA: _optAController.text,
            optionB: _optBController.text,
            optionC: _optCController.text,
            optionD: _optDController.text,
            correctOption: correctOptionString,
            explanation: _explanationController.text,
            difficulty: _difficulty,
            active: _isActive,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Pregunta añadida con éxito!'), backgroundColor: AppTheme.successColor),
        );
        _formKey.currentState!.reset();

        // Manual cleanup of text controllers
        _statementController.clear();
        _topicController.clear();
        _optAController.clear();
        _optBController.clear();
        _optCController.clear();
        _optDController.clear();
        _explanationController.clear();

        setState(() {
          _selectedSubject = null;
          _correctIndex = 1;
          _difficulty = 'Medio';
          _isActive = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsAdmin) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Acceso restringido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'Esta función solo está disponible\nen la versión de administrador.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aportar Pregunta',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _statementController,
                decoration: const InputDecoration(
                  labelText: 'Texto de la pregunta',
                  prefixIcon: Icon(Icons.help_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category)),
                      items: _subjects
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      isExpanded: true,
                      onChanged: (v) => setState(() => _selectedSubject = v),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _topicController,
                      decoration: const InputDecoration(labelText: 'Tema', prefixIcon: Icon(Icons.topic)),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Opciones de Respuesta:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...[1, 2, 3, 4].map((index) {
                final controller = index == 1
                    ? _optAController
                    : index == 2
                    ? _optBController
                    : index == 3
                    ? _optCController
                    : _optDController;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: _correctIndex,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (v) => setState(() => _correctIndex = v!),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText:
                                'Opción ${index == 1
                                    ? 'A'
                                    : index == 2
                                    ? 'B'
                                    : index == 3
                                    ? 'C'
                                    : 'D'}',
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              TextFormField(
                controller: _explanationController,
                decoration: const InputDecoration(labelText: 'Explicación', prefixIcon: Icon(Icons.info_outline)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _difficulty,
                      decoration: const InputDecoration(labelText: 'Dificultad', prefixIcon: Icon(Icons.speed)),
                      items: [
                        'Fácil',
                        'Medio',
                        'Difícil',
                      ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() => _difficulty = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Activa'),
                      value: _isActive,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar Pregunta', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 100), // Padding extra para scroll
            ],
          ),
        ),
      ),
    );
  }
}
