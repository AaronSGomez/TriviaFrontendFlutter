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
        padding: const EdgeInsets.all(24.0),
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
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        question.statement,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ...[1, 2, 3, 4].map((index) {
              final optionText = index == 1
                  ? question.optionA
                  : index == 2
                  ? question.optionB
                  : index == 3
                  ? question.optionC
                  : question.optionD;
              Color backgroundColor = AppTheme.surfaceColor;

              if (controller.selectedAnswer == index) {
                if (controller.isCorrect == null) {
                  backgroundColor = Colors.blueGrey;
                } else if (controller.isCorrect == true) {
                  backgroundColor = AppTheme.successColor;
                } else {
                  backgroundColor = AppTheme.errorColor;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: controller.selectedAnswer != null
                        ? null
                        : () => ref.read(gameControllerProvider(widget.sessionId)).answerQuestion(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Text(optionText, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
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
