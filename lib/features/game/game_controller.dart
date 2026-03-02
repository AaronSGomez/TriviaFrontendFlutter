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
  bool isFinished = false;

  GameController(this.ref, this.sessionId) {
    _loadNextQuestion();
  }

  Future<void> _loadNextQuestion() async {
    isLoading = true;
    selectedAnswer = null;
    isCorrect = null;
    notifyListeners();

    try {
      final repository = ref.read(gameRepositoryProvider);
      final question = await repository.getNextQuestion(sessionId);
      if (question == null) {
        isFinished = true;
      } else {
        currentQuestion = question;
        questionIndex++;
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
      isCorrect = await repository.submitAnswer(sessionId, answerIndex);
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1500));
      await _loadNextQuestion();
    } catch (e) {
      selectedAnswer = null;
      isCorrect = null;
      notifyListeners();
    }
  }
}
