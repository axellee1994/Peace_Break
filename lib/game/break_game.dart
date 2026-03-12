import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:async' as async;
import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/brick.dart';
import 'components/powerup.dart';
import 'stages/stage_config.dart';

enum GameState { playing, paused, won, lost }

class BreakGame extends FlameGame
    with HasCollisionDetection, DragCallbacks, TapCallbacks {
  final int stageNumber;
  final int maxLives;
  final Color? paddleColor;
  final Color? ballColor;

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);
  final ValueNotifier<int> livesNotifier;
  final ValueNotifier<GameState> stateNotifier =
      ValueNotifier(GameState.playing);

  late Paddle _paddle;
  late Ball _ball;
  int _bricksRemaining = 0;
  bool _ballInPlay = false;
  final List<async.Timer> _powerUpTimers = [];

  BreakGame({
    required this.stageNumber,
    required this.maxLives,
    this.paddleColor,
    this.ballColor,
  }) : livesNotifier = ValueNotifier(maxLives);

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildStage();
  }

  void _buildStage() {
    final config = StageConfig.get(stageNumber);
    if (config == null) return;

    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    ));

    const hudHeight = 60.0;
    const brickPadding = 4.0;
    const sidePadding = 8.0;
    final availableWidth = size.x - sidePadding * 2;
    final brickWidth =
        (availableWidth - brickPadding * (config.cols - 1)) / config.cols;
    const brickHeight = 20.0;

    _bricksRemaining = 0;

    for (int r = 0; r < config.rows; r++) {
      for (int c = 0; c < config.cols; c++) {
        final hp = config.grid[r][c];
        if (hp <= 0) continue;
        _bricksRemaining++;
        final bx = sidePadding + c * (brickWidth + brickPadding);
        final by = hudHeight + 10 + r * (brickHeight + brickPadding);
        add(Brick(
          position: Vector2(bx, by),
          size: Vector2(brickWidth, brickHeight),
          hitPoints: hp,
          onDestroyed: _onBrickDestroyed,
          onDropPowerUp: _spawnPowerUp,
        ));
      }
    }

    _paddle = Paddle(
      screenWidth: size.x,
      skinColor: paddleColor,
    )
      ..position = Vector2(size.x / 2, size.y - 40);
    add(_paddle);

    _spawnBall();
  }

  void _spawnBall() {
    _ballInPlay = false;
    _ball = Ball(
      startPosition:
          Vector2(_paddle.position.x, _paddle.position.y - 20),
      skinColor: ballColor,
      onFallOff: _onBallFallOff,
    )..velocity = Vector2(0, 0);
    add(_ball);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_ballInPlay &&
        stateNotifier.value == GameState.playing) {
      _launchBall();
    }
  }

  void _launchBall() {
    _ballInPlay = true;
    _ball.velocity = Vector2(0, -1);
  }

  void _onBallFallOff() {
    livesNotifier.value--;
    _ball.removeFromParent();
    if (livesNotifier.value <= 0) {
      stateNotifier.value = GameState.lost;
    } else {
      _spawnBall();
    }
  }

  void _onBrickDestroyed(int score, int coins) {
    scoreNotifier.value += score;
    coinsNotifier.value += coins;
    _bricksRemaining--;
    if (_bricksRemaining <= 0) {
      stateNotifier.value = GameState.won;
    }
  }

  void _spawnPowerUp(PowerUpType type, Vector2 position) {
    add(PowerUp(position: position, type: type));
  }

  void applyPowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.extraLife:
        livesNotifier.value++;
        break;
      case PowerUpType.paddleWide:
        _paddle.widen(1.5);
        _scheduleReset(() => _paddle.resetWidth(), 10);
        break;
      case PowerUpType.paddleNarrow:
        _paddle.widen(0.7);
        _scheduleReset(() => _paddle.resetWidth(), 10);
        break;
      case PowerUpType.speedUp:
        _ball.setSpeed(480);
        _scheduleReset(() => _ball.resetSpeed(), 10);
        break;
    }
  }

  void _scheduleReset(VoidCallback action, int seconds) {
    final t = async.Timer(Duration(seconds: seconds), action);
    _powerUpTimers.add(t);
  }

  void togglePause() {
    if (stateNotifier.value == GameState.paused) {
      stateNotifier.value = GameState.playing;
      resumeEngine();
    } else if (stateNotifier.value == GameState.playing) {
      stateNotifier.value = GameState.paused;
      pauseEngine();
    }
  }

  @override
  void update(double dt) {
    if (stateNotifier.value != GameState.playing) return;
    super.update(dt);

    if (!_ballInPlay) {
      _ball.position =
          Vector2(_paddle.position.x, _paddle.position.y - 20);
    }

    final powerUps = children.whereType<PowerUp>().toList();
    for (final pu in powerUps) {
      if (_paddle.toRect().overlaps(pu.toRect())) {
        applyPowerUp(pu.type);
        pu.removeFromParent();
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (stateNotifier.value != GameState.playing) return;
    _paddle.position.x += event.localDelta.x;
    final half = _paddle.size.x / 2;
    _paddle.position.x =
        _paddle.position.x.clamp(half, size.x - half);
    if (!_ballInPlay) {
      _ball.position.x = _paddle.position.x;
    }
  }

  @override
  void onRemove() {
    for (final t in _powerUpTimers) {
      t.cancel();
    }
    super.onRemove();
  }
}
