import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../database/app_database.dart';
import '../models/stage_result.dart';

class CompletedStagesScreen extends StatefulWidget {
  const CompletedStagesScreen({super.key});

  @override
  State<CompletedStagesScreen> createState() =>
      _CompletedStagesScreenState();
}

class _CompletedStagesScreenState extends State<CompletedStagesScreen> {
  List<StageResult> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final results =
        await AppDatabase().stageResults.forUser(user.id!);
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Completed Stages')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? const Center(
                  child: Text('No completed stages yet. Start playing!',
                      style: TextStyle(fontSize: 16)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = _results[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.primaryContainer,
                          child: Text('${r.stageNumber}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onPrimaryContainer)),
                        ),
                        title: Text('Stage ${r.stageNumber}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.star, size: 14,
                                color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('Best: ${r.score}'),
                            const SizedBox(width: 12),
                            const Icon(Icons.monetization_on,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${r.coinsEarned}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _replay(r.stageNumber),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.secondary,
                            foregroundColor: cs.onSecondary,
                          ),
                          child: const Text('Replay'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _replay(int stageNumber) {
    final user = context.read<AuthProvider>().currentUser!;
    context.read<GameProvider>().initStage(user.maxLives);
    Navigator.pushNamed(context, '/game', arguments: stageNumber)
        .then((_) => _load());
  }
}
