import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/question.dart';
import '../../domain/repositories/game_repository.dart';

final gameControllerProvider = ChangeNotifierProvider.family<GameController, String>((ref, sessionId) {
  return GameController(ref, sessionId);
});

class GameController extends ChangeNotifier {
  final Ref ref;
  final String sessionId;

  Question? currentQuestion;
  bool isLoading = true;
  int questionIndex = 0;
  int? selectedAnswer;
  bool? isCorrect;
  String? backendExplanation;
  String? correctBackendOption;
  bool isFinished = false;
  DateTime? _questionStartTime;

  GameController(this.ref, this.sessionId) {
    _loadNextQuestion();
  }

  Future<void> _loadNextQuestion() async {
    isLoading = true;
    selectedAnswer = null;
    isCorrect = null;
    backendExplanation = null;
    correctBackendOption = null;
    notifyListeners();

    try {
      final repository = ref.read(gameRepositoryProvider);
      final question = await repository.getNextQuestion(sessionId);
      if (question == null) {
        isFinished = true;
      } else {
        currentQuestion = question;
        questionIndex++;
        _questionStartTime = DateTime.now();
      }
    } catch (e) {
      // Error handling
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> answerQuestion(int answerIndex) async {
    if (selectedAnswer != null || isLoading) return;

    selectedAnswer = answerIndex;
    notifyListeners();

    try {
      final repository = ref.read(gameRepositoryProvider);

      final selectedOptionStr = ['optionA', 'optionB', 'optionC', 'optionD'][answerIndex - 1];
      final questionId = currentQuestion!.id!;
      final timeElapsedSeconds = _questionStartTime != null
          ? DateTime.now().difference(_questionStartTime!).inSeconds
          : 0;

      final result = await repository.submitAnswer(sessionId, questionId, selectedOptionStr, timeElapsedSeconds);
      isCorrect = result.isCorrect;
      backendExplanation = result.explanation;
      correctBackendOption = result.correctAnswer;

      notifyListeners();
    } catch (e) {
      selectedAnswer = null;
      isCorrect = null;
      backendExplanation = null;
      correctBackendOption = null;
      notifyListeners();
    }
  }

  Future<void> skipQuestion() async {
    if (selectedAnswer != null || isLoading) return;

    selectedAnswer = -1; // -1 represents skipped
    notifyListeners();

    try {
      final repository = ref.read(gameRepositoryProvider);

      final questionId = currentQuestion!.id!;
      final timeElapsedSeconds = _questionStartTime != null
          ? DateTime.now().difference(_questionStartTime!).inSeconds
          : 0;

      final result = await repository.submitAnswer(sessionId, questionId, 'SKIP', timeElapsedSeconds);
      isCorrect = false;
      backendExplanation = result.explanation;
      correctBackendOption = result.correctAnswer;

      notifyListeners();
    } catch (e) {
      selectedAnswer = null;
      isCorrect = null;
      backendExplanation = null;
      correctBackendOption = null;
      notifyListeners();
    }
  }

  void nextQuestion() {
    _loadNextQuestion();
  }
}
