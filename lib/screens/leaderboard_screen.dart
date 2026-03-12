import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../database/app_database.dart';
import '../models/user.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<User> _top = [];
  int _myRank = -1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    final db = AppDatabase();
    final top = await db.users.topByScore(10);
    final rank = user != null ? await db.users.rankOf(user.id!) : -1;
    setState(() {
      _top = top;
      _myRank = rank;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final me = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (me != null && _myRank > 0)
                  Container(
                    color: cs.primaryContainer,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events, color: cs.primary),
                        const SizedBox(width: 8),
                        Text('Your rank: #$_myRank',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const Spacer(),
                        Text('${me.totalScore} pts'),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _top.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final u = _top[i];
                      final rank = i + 1;
                      final isMe = u.id == me?.id;

                      return ListTile(
                        tileColor: isMe
                            ? cs.primaryContainer.withOpacity(0.4)
                            : null,
                        leading: CircleAvatar(
                          backgroundColor: _rankColor(rank),
                          child: Text('$rank',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        title: Row(
                          children: [
                            Text(u.username,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isMe ? cs.primary : null)),
                            if (isMe) ...[
                              const SizedBox(width: 6),
                              Chip(
                                label: const Text('You',
                                    style: TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                                backgroundColor: cs.primary,
                                labelStyle:
                                    TextStyle(color: cs.onPrimary),
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('${u.totalScore}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }
}
