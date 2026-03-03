class GameResult {
  final int score;
  final double grade;
  final bool isPassed;

  const GameResult({required this.score, required this.grade, required this.isPassed});

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      score: json['score'] as int,
      grade: (json['grade'] as num).toDouble(),
      isPassed: json['passed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'score': score, 'grade': grade, 'isPassed': isPassed};
}
