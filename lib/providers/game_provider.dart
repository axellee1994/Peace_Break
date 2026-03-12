import 'package:flutter/foundation.dart';
import '../database/app_database.dart';

class GameProvider extends ChangeNotifier {
  final AppDatabase db;

  GameProvider(this.db);

  int _score = 0;
  int _coins = 0;
  int _lives = 3;
  int _maxLives = 3;
  bool _isPaused = false;

  int get score => _score;
  int get coins => _coins;
  int get lives => _lives;
  int get maxLives => _maxLives;
  bool get isPaused => _isPaused;
  bool get isDead => _lives <= 0;

  void initStage(int maxLives) {
    _score = 0;
    _coins = 0;
    _lives = maxLives;
    _maxLives = maxLives;
    _isPaused = false;
    notifyListeners();
  }

  void addScore(int points) {
    _score += points;
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    notifyListeners();
  }

  void loseLife() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
    }
  }

  void gainLife() {
    _lives++;
    notifyListeners();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  /// Persist win result: upsert best score, add coins & score to user totals.
  Future<void> saveWin({
    required int userId,
    required int stageNumber,
  }) async {
    await db.stageResults.upsertBest(
      userId: userId,
      stageNumber: stageNumber,
      score: _score,
      coinsEarned: _coins,
    );
    final user = await db.users.findById(userId);
    if (user != null) {
      await db.users.updateFields(userId, {
        'total_score': user.totalScore + _score,
        'coins': user.coins + _coins,
      });
    }
  }
}
