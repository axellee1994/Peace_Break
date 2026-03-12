import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/app_database.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/completed_stages_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/settings_screen.dart';
import 'game/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await db.init();
  runApp(PeaceBreakApp(db: db));
}

class PeaceBreakApp extends StatelessWidget {
  final AppDatabase db;
  const PeaceBreakApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(db)),
        ChangeNotifierProvider(create: (_) => GameProvider(db)),
      ],
      child: MaterialApp(
        title: 'Peace Break',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/menu': (_) => const MainMenuScreen(),
          '/shop': (_) => const ShopScreen(),
          '/inventory': (_) => const InventoryScreen(),
          '/completed': (_) => const CompletedStagesScreen(),
          '/leaderboard': (_) => const LeaderboardScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/game': (_) => const GameScreen(),
        },
      ),
    );
  }
}
