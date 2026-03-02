class GameSession {
  final String id;
  final String playerId;
  final String subject;
  final int totalQuestions;
  final bool isActive;
  final int? currentScore;

  const GameSession({
    required this.id,
    required this.playerId,
    required this.subject,
    required this.totalQuestions,
    required this.isActive,
    this.currentScore,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      subject: json['subject'] as String,
      totalQuestions: json['totalQuestions'] as int,
      isActive: json['isActive'] as bool,
      currentScore: json['currentScore'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'playerId': playerId,
    'subject': subject,
    'totalQuestions': totalQuestions,
    'isActive': isActive,
    'currentScore': currentScore,
  };
}
