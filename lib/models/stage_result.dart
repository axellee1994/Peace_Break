import '../database/orm.dart';

class StageResult implements Model {
  @override
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

  @override
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'stage_number': stageNumber,
        'score': score,
        'coins_earned': coinsEarned,
        'completed_at': completedAt,
      };

  factory StageResult.fromMap(Map<String, dynamic> m) => StageResult(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        stageNumber: m['stage_number'] as int,
        score: m['score'] as int,
        coinsEarned: m['coins_earned'] as int,
        completedAt: m['completed_at'] as String,
      );
}
