class Question {
  final int? id;
  final String statement;
  final String subject;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String? correctOption;
  final String? explanation;
  final String? topic;
  final String? difficulty;
  final bool? active;

  const Question({
    this.id,
    required this.statement,
    required this.subject,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    this.correctOption,
    this.explanation,
    this.topic,
    this.difficulty,
    this.active,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int?,
      statement: json['statement'] as String? ?? json['text'] as String? ?? '', // Fallback for backwards compat
      subject: json['subject'] as String? ?? '',
      optionA: json['optionA'] as String? ?? '',
      optionB: json['optionB'] as String? ?? '',
      optionC: json['optionC'] as String? ?? '',
      optionD: json['optionD'] as String? ?? '',
      correctOption: json['correctOption'] as String?,
      explanation: json['explanation'] as String?,
      topic: json['topic'] as String?,
      difficulty: json['difficulty'] as String?,
      active: json['active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'statement': statement,
    'subject': subject,
    'optionA': optionA,
    'optionB': optionB,
    'optionC': optionC,
    'optionD': optionD,
    if (correctOption != null) 'correctOption': correctOption,
    if (explanation != null) 'explanation': explanation,
    if (topic != null) 'topic': topic,
    if (difficulty != null) 'difficulty': difficulty,
    if (active != null) 'active': active,
  };
}
