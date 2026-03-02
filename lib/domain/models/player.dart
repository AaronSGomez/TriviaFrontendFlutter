class Player {
  final String id;
  final String name;
  final String mail;
  final int totalScore;

  const Player({required this.id, required this.name, required this.mail, this.totalScore = 0});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      mail: json['mail'] as String,
      totalScore: json['totalScore'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'mail': mail, 'totalScore': totalScore};
}
