import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../database/app_database.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: cs.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: cs.primary,
                        child: Text(
                          user.username[0].toUpperCase(),
                          style: TextStyle(
                              fontSize: 28,
                              color: cs.onPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(user.username,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Stat(
                              icon: Icons.star,
                              label: 'Score',
                              value: '${user.totalScore}'),
                          _Stat(
                              icon: Icons.monetization_on,
                              label: 'Coins',
                              value: '${user.coins}'),
                          _Stat(
                              icon: Icons.favorite,
                              label: 'Max Lives',
                              value: '${user.maxLives}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<int>(
                future: AppDatabase().stageResults.forUser(user.id!).then(
                    (results) => results.isEmpty
                        ? 1
                        : results.last.stageNumber + 1 > 10
                            ? 10
                            : results.last.stageNumber + 1),
                builder: (context, snap) {
                  final nextStage = snap.data ?? 1;
                  return ElevatedButton.icon(
                    onPressed: () {
                      context.read<GameProvider>().initStage(user.maxLives);
                      Navigator.pushNamed(context, '/game',
                          arguments: nextStage);
                    },
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: Text('PLAY STAGE $nextStage',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _NavCard(
                        icon: Icons.storefront,
                        label: 'Shop',
                        route: '/shop'),
                    _NavCard(
                        icon: Icons.backpack,
                        label: 'Inventory',
                        route: '/inventory'),
                    _NavCard(
                        icon: Icons.check_circle,
                        label: 'Completed',
                        route: '/completed'),
                    _NavCard(
                        icon: Icons.leaderboard,
                        label: 'Leaderboard',
                        route: '/leaderboard'),
                    _NavCard(
                        icon: Icons.settings,
                        label: 'Settings',
                        route: '/settings'),
                    _NavCard(
                        icon: Icons.logout,
                        label: 'Logout',
                        route: '',
                        onTap: () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, size: 20),
      Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final VoidCallback? onTap;

  const _NavCard(
      {required this.icon,
      required this.label,
      required this.route,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () async {
              await Navigator.pushNamed(context, route);
              if (context.mounted) {
                context.read<AuthProvider>().refreshUser();
              }
            },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: cs.primary),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
