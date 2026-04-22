import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/question.dart';
import '../../domain/repositories/game_repository.dart';
import 'question_review_item.dart';

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
  List<String> shuffledOptionKeys = const [];
  bool isFinished = false;
  bool isSessionFinished = false;
  final List<QuestionReviewItem> failedQuestions = [];
  DateTime? _questionStartTime;
  final Random _random = Random();

  GameController(this.ref, this.sessionId) {
    _loadNextQuestion();
  }

  Future<void> _loadNextQuestion() async {
    isLoading = true;
    currentQuestion = null;
    selectedAnswer = null;
    isCorrect = null;
    backendExplanation = null;
    correctBackendOption = null;
    shuffledOptionKeys = const [];
    notifyListeners();

    try {
      final repository = ref.read(gameRepositoryProvider);
      final question = await repository.getNextQuestion(sessionId);
      if (question == null) {
        isFinished = true;
      } else {
        currentQuestion = question;
        final keys = ['optionA', 'optionB', 'optionC', 'optionD'];
        keys.shuffle(_random);
        shuffledOptionKeys = List.unmodifiable(keys);
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

        final selectedOptionStr = optionKeyForIndex(answerIndex);
      final questionId = currentQuestion!.id!;
      final timeElapsedSeconds = _questionStartTime != null
          ? DateTime.now().difference(_questionStartTime!).inSeconds
          : 0;

      final result = await repository.submitAnswer(sessionId, questionId, selectedOptionStr, timeElapsedSeconds);
      isCorrect = result.isCorrect;
      backendExplanation = result.explanation;
      correctBackendOption = result.correctAnswer;
      isSessionFinished = result.isSessionFinished;

      if (result.isCorrect == false) {
        failedQuestions.add(
          QuestionReviewItem(
            question: currentQuestion!,
            selectedAnswerIndex: answerIndex,
            selectedOptionKey: selectedOptionStr,
            isCorrect: result.isCorrect,
            correctOptionKey: result.correctAnswer,
            explanation: result.explanation,
            timeElapsedSeconds: timeElapsedSeconds,
          ),
        );
      }
      // Single notify after all state changes to reduce UI rebuilds
      notifyListeners();

      // Auto-advance to next question if session is finished
      if (isSessionFinished) {
        isFinished = true;
        notifyListeners();
      }
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
      isSessionFinished = result.isSessionFinished;

      failedQuestions.add(
        QuestionReviewItem(
          question: currentQuestion!,
          selectedAnswerIndex: -1,
          selectedOptionKey: 'SKIP',
          isCorrect: false,
          correctOptionKey: result.correctAnswer,
          explanation: result.explanation,
          timeElapsedSeconds: timeElapsedSeconds,
        ),
      );
      // Single notify after all state changes to reduce UI rebuilds
      notifyListeners();

      // Auto-advance to next question if session is finished
      if (isSessionFinished) {
        isFinished = true;
        notifyListeners();
      }
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

  String optionKeyForIndex(int index) {
    if (index < 1 || index > 4 || shuffledOptionKeys.length != 4) {
      return 'optionA';
    }
    return shuffledOptionKeys[index - 1];
  }

  String optionTextForIndex(int index) {
    return optionTextByKey(optionKeyForIndex(index));
  }

  String optionTextByKey(String key) {
    final question = currentQuestion;
    if (question == null) return '';

    return switch (key) {
      'optionA' => question.optionA,
      'optionB' => question.optionB,
      'optionC' => question.optionC,
      'optionD' => question.optionD,
      _ => '',
    };
  }
}
