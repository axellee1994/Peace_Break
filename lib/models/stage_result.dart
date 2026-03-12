class StageResult {
  final int? id;
  final int userId;
  final int stageNumber;
  final int score;
  final int coinsEarned;
  final String completedAt;

  const StageResult({
    this.id,
    required this.userId,
    required this.stageNumber,
    required this.score,
    required this.coinsEarned,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'stage_number': stageNumber,
      'score': score,
      'coins_earned': coinsEarned,
      'completed_at': completedAt,
    };
  }

  factory StageResult.fromMap(Map<String, dynamic> map) {
    return StageResult(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      stageNumber: map['stage_number'] as int,
      score: map['score'] as int,
      coinsEarned: map['coins_earned'] as int,
      completedAt: map['completed_at'] as String,
    );
  }
}
