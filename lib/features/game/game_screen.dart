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

  static final RegExp _statementImagePattern = RegExp(r'^\s*\[IMAGE:([^\]]+)\]\s*', caseSensitive: false);

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

    final parsedStatement = _parseStatement(question.statement);

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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (parsedStatement.imageName != null) ...[
                              _QuestionImage(
                                imagePath: 'assets/${parsedStatement.imageName}',
                                onTap: () => _showZoomableImageDialog('assets/${parsedStatement.imageName}'),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              parsedStatement.statement,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.selectedAnswer != null
                        ? null
                        : () => ref.read(gameControllerProvider(widget.sessionId)).answerQuestion(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: backgroundColor, // Maintain color when disabled
                      disabledForegroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.3)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        controller.backendExplanation!,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
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
            const SizedBox(height: 4),
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

  ({String? imageName, String statement}) _parseStatement(String rawStatement) {
    final match = _statementImagePattern.firstMatch(rawStatement);
    if (match == null) {
      return (imageName: null, statement: rawStatement);
    }

    final imageName = match.group(1)?.trim();
    final textOnly = rawStatement.replaceFirst(_statementImagePattern, '').trimLeft();
    return (imageName: (imageName == null || imageName.isEmpty) ? null : imageName, statement: textOnly);
  }

  void _showZoomableImageDialog(String imagePath) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black87,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, stackTrace) => const Center(
                      child: Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionImage extends StatelessWidget {
  const _QuestionImage({required this.imagePath, required this.onTap});

  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.zoom_in, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Ampliar',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
