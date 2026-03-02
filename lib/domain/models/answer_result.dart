class AnswerResult {
  final bool isCorrect;
  final String correctAnswer;
  final int currentScore;
  final bool isSessionFinished;
  final String? explanation;

  const AnswerResult({
    required this.isCorrect,
    required this.correctAnswer,
    required this.currentScore,
    required this.isSessionFinished,
    this.explanation,
  });

  factory AnswerResult.fromJson(Map<String, dynamic> json) {
    return AnswerResult(
      isCorrect: json['isCorrect'] as bool? ?? false,
      correctAnswer: json['correctAnswer'] as String? ?? '',
      currentScore: json['currentScore'] as int? ?? 0,
      isSessionFinished: json['isSessionFinished'] as bool? ?? false,
      explanation: json['explanation'] as String?,
    );
  }
}
