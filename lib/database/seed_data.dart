import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SeedData {
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> seed(Database db) async {
    // Seed shop items first
    final shopItems = [
      {
        'name': 'Life+',
        'type': 'life',
        'price': 500,
        'description': 'Permanently increases your max lives by 1',
      },
      {
        'name': 'Paddle Skin 1',
        'type': 'paddle_skin',
        'price': 200,
        'description': 'Cool blue metallic paddle skin',
      },
      {
        'name': 'Paddle Skin 2',
        'type': 'paddle_skin',
        'price': 300,
        'description': 'Fiery red paddle skin',
      },
      {
        'name': 'Ball Skin 1',
        'type': 'ball_skin',
        'price': 150,
        'description': 'Golden ball skin',
      },
      {
        'name': 'Ball Skin 2',
        'type': 'ball_skin',
        'price': 250,
        'description': 'Neon green ball skin',
      },
    ];

    for (final item in shopItems) {
      await db.insert('shop_items', item);
    }

    // Seed 20 users
    final passwordHash = _hashPassword('Password1!');
    final now = DateTime.now().toIso8601String();

    final users = [
      {'email': 'alice@example.com', 'username': 'alice', 'coins': 1200, 'total_score': 45000, 'max_lives': 4},
      {'email': 'bob@example.com', 'username': 'bob', 'coins': 800, 'total_score': 32000, 'max_lives': 3},
      {'email': 'carol@example.com', 'username': 'carol', 'coins': 2500, 'total_score': 78000, 'max_lives': 5},
      {'email': 'dave@example.com', 'username': 'dave', 'coins': 350, 'total_score': 15000, 'max_lives': 3},
      {'email': 'eve@example.com', 'username': 'eve', 'coins': 950, 'total_score': 29000, 'max_lives': 3},
      {'email': 'frank@example.com', 'username': 'frank', 'coins': 3100, 'total_score': 92000, 'max_lives': 6},
      {'email': 'grace@example.com', 'username': 'grace', 'coins': 600, 'total_score': 21000, 'max_lives': 3},
      {'email': 'hank@example.com', 'username': 'hank', 'coins': 1800, 'total_score': 55000, 'max_lives': 4},
      {'email': 'iris@example.com', 'username': 'iris', 'coins': 420, 'total_score': 18500, 'max_lives': 3},
      {'email': 'jack@example.com', 'username': 'jack', 'coins': 2200, 'total_score': 67000, 'max_lives': 5},
      {'email': 'kate@example.com', 'username': 'kate', 'coins': 750, 'total_score': 25000, 'max_lives': 3},
      {'email': 'leo@example.com', 'username': 'leo', 'coins': 1600, 'total_score': 48000, 'max_lives': 4},
      {'email': 'mia@example.com', 'username': 'mia', 'coins': 90, 'total_score': 5000, 'max_lives': 3},
      {'email': 'noah@example.com', 'username': 'noah', 'coins': 3800, 'total_score': 110000, 'max_lives': 6},
      {'email': 'olivia@example.com', 'username': 'olivia', 'coins': 270, 'total_score': 12000, 'max_lives': 3},
      {'email': 'peter@example.com', 'username': 'peter', 'coins': 1100, 'total_score': 38000, 'max_lives': 4},
      {'email': 'quinn@example.com', 'username': 'quinn', 'coins': 500, 'total_score': 19000, 'max_lives': 3},
      {'email': 'rachel@example.com', 'username': 'rachel', 'coins': 2900, 'total_score': 85000, 'max_lives': 5},
      {'email': 'sam@example.com', 'username': 'sam', 'coins': 680, 'total_score': 23000, 'max_lives': 3},
      {'email': 'tina@example.com', 'username': 'tina', 'coins': 4200, 'total_score': 125000, 'max_lives': 7},
    ];

    final List<int> userIds = [];
    for (final user in users) {
      final id = await db.insert('users', {
        'email': user['email'],
        'username': user['username'],
        'password_hash': passwordHash,
        'coins': user['coins'],
        'total_score': user['total_score'],
        'max_lives': user['max_lives'],
        'created_at': now,
      });
      userIds.add(id);
    }

    // Stage completions per user (based on their score level)
    final stageCompletions = [
      // alice: stages 1-5
      [1, 2, 3, 4, 5],
      // bob: stages 1-4
      [1, 2, 3, 4],
      // carol: stages 1-8
      [1, 2, 3, 4, 5, 6, 7, 8],
      // dave: stages 1-2
      [1, 2],
      // eve: stages 1-3
      [1, 2, 3],
      // frank: stages 1-10
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      // grace: stages 1-3
      [1, 2, 3],
      // hank: stages 1-6
      [1, 2, 3, 4, 5, 6],
      // iris: stages 1-2
      [1, 2],
      // jack: stages 1-7
      [1, 2, 3, 4, 5, 6, 7],
      // kate: stages 1-3
      [1, 2, 3],
      // leo: stages 1-5
      [1, 2, 3, 4, 5],
      // mia: stage 1 only
      [1],
      // noah: stages 1-10
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      // olivia: stages 1-2
      [1, 2],
      // peter: stages 1-4
      [1, 2, 3, 4],
      // quinn: stages 1-2
      [1, 2],
      // rachel: stages 1-9
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      // sam: stages 1-3
      [1, 2, 3],
      // tina: stages 1-10
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    ];

    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final stages = stageCompletions[i];
      for (final stage in stages) {
        final score = (stage * 1000) + (i * 100) + 500;
        final coins = stage * 50 + 20;
        await db.insert('stage_results', {
          'user_id': userId,
          'stage_number': stage,
          'score': score,
          'coins_earned': coins,
          'completed_at': now,
        });
      }
    }

    // Give some users inventory items
    // carol owns paddle skin 1 and ball skin 1
    await db.insert('inventory', {'user_id': userIds[2], 'item_id': 2, 'is_equipped': 1});
    await db.insert('inventory', {'user_id': userIds[2], 'item_id': 4, 'is_equipped': 1});
    // frank owns all skins
    await db.insert('inventory', {'user_id': userIds[5], 'item_id': 2, 'is_equipped': 0});
    await db.insert('inventory', {'user_id': userIds[5], 'item_id': 3, 'is_equipped': 1});
    await db.insert('inventory', {'user_id': userIds[5], 'item_id': 4, 'is_equipped': 0});
    await db.insert('inventory', {'user_id': userIds[5], 'item_id': 5, 'is_equipped': 1});
    // noah owns some skins
    await db.insert('inventory', {'user_id': userIds[13], 'item_id': 3, 'is_equipped': 1});
    await db.insert('inventory', {'user_id': userIds[13], 'item_id': 5, 'is_equipped': 1});
    // tina owns all
    await db.insert('inventory', {'user_id': userIds[19], 'item_id': 2, 'is_equipped': 1});
    await db.insert('inventory', {'user_id': userIds[19], 'item_id': 3, 'is_equipped': 0});
    await db.insert('inventory', {'user_id': userIds[19], 'item_id': 4, 'is_equipped': 1});
    await db.insert('inventory', {'user_id': userIds[19], 'item_id': 5, 'is_equipped': 0});
  }
}
