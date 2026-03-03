import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../../core/theme.dart';
import 'game_controller.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const GameScreen({super.key, required this.sessionId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(gameControllerProvider(widget.sessionId));

    // Handle game finish
    if (controller.isFinished && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/results', extra: widget.sessionId);
      });
    }

    // Handle vibration
    if (controller.isCorrect == false) {
      _vibrateOnce();
    }

    if (controller.isLoading && controller.currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = controller.currentQuestion;
    if (question == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: Text('Pregunta ${controller.questionIndex}'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'question_card',
                  child: Card(
                    color: AppTheme.surfaceColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Text(
                          question.statement,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...[1, 2, 3, 4].map((index) {
              final optionText = index == 1
                  ? question.optionA
                  : index == 2
                  ? question.optionB
                  : index == 3
                  ? question.optionC
                  : question.optionD;
              Color backgroundColor = AppTheme.surfaceColor;

              if (controller.selectedAnswer != null) {
                if (index == controller.selectedAnswer) {
                  // The button the user clicked
                  if (controller.isCorrect == null) {
                    backgroundColor = AppTheme.primaryColor;
                  } else {
                    backgroundColor = controller.isCorrect! ? AppTheme.successColor : AppTheme.errorColor;
                  }
                } else if (controller.correctBackendOption != null) {
                  // Another button that happens to be the correct one
                  final optionKeys = ['optionA', 'optionB', 'optionC', 'optionD'];
                  if (optionKeys[index - 1] == controller.correctBackendOption) {
                    backgroundColor = AppTheme.successColor;
                  }
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.selectedAnswer != null
                        ? null
                        : () => ref.read(gameControllerProvider(widget.sessionId)).answerQuestion(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: backgroundColor, // Maintain color when disabled
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: (controller.selectedAnswer == index && controller.isCorrect == null)
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            optionText,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              );
            }),
            if (controller.selectedAnswer != null) ...[
              const SizedBox(height: 8),
              if (controller.backendExplanation != null && controller.backendExplanation!.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        controller.backendExplanation!,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => ref.read(gameControllerProvider(widget.sessionId)).nextQuestion(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Siguiente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _hasVibrated = false;

  void _vibrateOnce() async {
    if (_hasVibrated) return;
    _hasVibrated = true;
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate();
      }
    } catch (_) {}
  }
}
