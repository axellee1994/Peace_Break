import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../database/app_database.dart';
import 'break_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  BreakGame? _game;
  int _stageNumber = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_game == null) {
      _stageNumber = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
      _initGame();
    }
  }

  Future<void> _initGame() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final db = AppDatabase();
    final inv = await db.inventory.forUser(user.id!);
    final allShop = await db.shopItems.findAll();
    final shopMap = {for (final s in allShop) s.id!: s};

    Color? paddleColor;
    Color? ballColor;
    for (final i in inv) {
      if (!i.isEquipped) continue;
      final item = shopMap[i.itemId];
      if (item == null) continue;
      if (item.type == 'paddle_skin') {
        paddleColor = item.name.contains('Fire')
            ? Colors.deepOrange
            : Colors.lightBlue;
      } else if (item.type == 'ball_skin') {
        ballColor =
            item.name.contains('Star') ? Colors.amber : Colors.greenAccent;
      }
    }

    final game = BreakGame(
      stageNumber: _stageNumber,
      maxLives: user.maxLives,
      paddleColor: paddleColor,
      ballColor: ballColor,
    );

    game.stateNotifier.addListener(() => _onGameStateChange(game));

    setState(() => _game = game);
  }

  void _onGameStateChange(BreakGame game) {
    if (game.stateNotifier.value == GameState.won) {
      _handleWin(game);
    } else if (game.stateNotifier.value == GameState.lost) {
      _handleLoss(game);
    }
  }

  Future<void> _handleWin(BreakGame game) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;

    final score = game.scoreNotifier.value;
    final coins = game.coinsNotifier.value;

    await AppDatabase().stageResults.upsertBest(
      userId: user.id!,
      stageNumber: _stageNumber,
      score: score,
      coinsEarned: coins,
    );
    final fresh = await AppDatabase().users.findById(user.id!);
    if (fresh != null) {
      await AppDatabase().users.updateFields(user.id!, {
        'total_score': fresh.totalScore + score,
        'coins': fresh.coins + coins,
      });
    }
    await auth.refreshUser();

    if (!mounted) return;
    _showWinDialog(score, coins);
  }

  Future<void> _handleLoss(BreakGame game) async {
    if (!mounted) return;
    _showLossDialog();
  }

  void _showWinDialog(int score, int coins) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Stage Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(children: [
                const Icon(Icons.star, color: Colors.amber, size: 32),
                Text('$score pts',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Score'),
              ]),
              Column(children: [
                const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 32),
                Text('+$coins',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Coins'),
              ]),
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/menu');
            },
            child: const Text('Menu'),
          ),
          if (_stageNumber < 10)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, '/game',
                    arguments: _stageNumber + 1);
              },
              child: const Text('Next Stage'),
            ),
        ],
      ),
    );
  }

  void _showLossDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Game Over 💀'),
        content: const Text('You ran out of lives!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/menu');
            },
            child: const Text('Menu'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/game',
                  arguments: _stageNumber);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_game == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game!),
          SafeArea(
            child: _HudOverlay(game: _game!, stageNumber: _stageNumber),
          ),
        ],
      ),
    );
  }
}

class _HudOverlay extends StatelessWidget {
  final BreakGame game;
  final int stageNumber;

  const _HudOverlay({required this.game, required this.stageNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.black.withOpacity(0.6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text('Stage $stageNumber',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const Spacer(),
          ValueListenableBuilder<int>(
            valueListenable: game.livesNotifier,
            builder: (_, lives, __) => Row(
              children: List.generate(
                lives.clamp(0, 7),
                (_) => const Icon(Icons.favorite,
                    color: Colors.red, size: 16),
              ),
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<int>(
            valueListenable: game.scoreNotifier,
            builder: (_, score, __) => Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 2),
              Text('$score',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(width: 12),
          ValueListenableBuilder<int>(
            valueListenable: game.coinsNotifier,
            builder: (_, coins, __) => Row(children: [
              const Icon(Icons.monetization_on,
                  color: Colors.amber, size: 16),
              const SizedBox(width: 2),
              Text('$coins',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => game.togglePause(),
            child: ValueListenableBuilder<GameState>(
              valueListenable: game.stateNotifier,
              builder: (_, state, __) => Icon(
                state == GameState.paused
                    ? Icons.play_arrow
                    : Icons.pause,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
