class GameSession {
  final String id;
  final String playerId;
  final String subject;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final int score;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String status;
  final double grade;
  final bool passed;

  const GameSession({
    required this.id,
    required this.playerId,
    required this.subject,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.score,
    required this.startedAt,
    this.finishedAt,
    required this.status,
    required this.grade,
    required this.passed,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      subject: json['subject'] as String,
      totalQuestions: json['totalQuestions'] as int,
      answeredQuestions: json['answeredQuestions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      startedAt: DateTime.parse(json['startedAt'] as String),
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt'] as String) : null,
      status: json['status'] as String? ?? 'UNKNOWN',
      grade: (json['grade'] as num?)?.toDouble() ?? 0.0,
      passed: json['passed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'playerId': playerId,
    'subject': subject,
    'totalQuestions': totalQuestions,
    'answeredQuestions': answeredQuestions,
    'correctAnswers': correctAnswers,
    'score': score,
    'startedAt': startedAt.toIso8601String(),
    'finishedAt': finishedAt?.toIso8601String(),
    'status': status,
    'grade': grade,
    'passed': passed,
  };
}
