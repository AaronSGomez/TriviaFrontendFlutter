import '../../domain/models/question.dart';

class QuestionReviewItem {
  final Question question;
  final int selectedAnswerIndex;
  final String selectedOptionKey;
  final bool isCorrect;
  final String correctOptionKey;
  final String? explanation;
  final int timeElapsedSeconds;

  const QuestionReviewItem({
    required this.question,
    required this.selectedAnswerIndex,
    required this.selectedOptionKey,
    required this.isCorrect,
    required this.correctOptionKey,
    required this.timeElapsedSeconds,
    this.explanation,
  });

  String get selectedOptionText => switch (selectedOptionKey) {
    'optionA' => question.optionA,
    'optionB' => question.optionB,
    'optionC' => question.optionC,
    'optionD' => question.optionD,
    'SKIP' => 'Omitida',
    _ => 'Omitida',
  };

  String get correctOptionText => switch (correctOptionKey) {
    'optionA' => question.optionA,
    'optionB' => question.optionB,
    'optionC' => question.optionC,
    'optionD' => question.optionD,
    _ => '',
  };
}
