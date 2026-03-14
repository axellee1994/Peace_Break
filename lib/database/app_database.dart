import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'repositories.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  Database? _db;

  AppDatabase._();
  factory AppDatabase() => _instance;

  late final UserRepository users;
  late final StageResultRepository stageResults;
  late final ShopItemRepository shopItems;
  late final InventoryItemRepository inventory;

  Database get rawDb => _db!;

  Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'peace_break.db');

    _db = await openDatabase(path, version: 1, onCreate: _onCreate);

    users = UserRepository(_db!);
    stageResults = StageResultRepository(_db!);
    shopItems = ShopItemRepository(_db!);
    inventory = InventoryItemRepository(_db!);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        coins INTEGER NOT NULL DEFAULT 0,
        total_score INTEGER NOT NULL DEFAULT 0,
        max_lives INTEGER NOT NULL DEFAULT 3,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE stage_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        stage_number INTEGER NOT NULL,
        score INTEGER NOT NULL,
        coins_earned INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE shop_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        price INTEGER NOT NULL,
        description TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        is_equipped INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (item_id) REFERENCES shop_items(id)
      )
    ''');

    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final paddleFireId = await db.insert('shop_items', {
      'name': 'Paddle: Fire',
      'type': 'paddle_skin',
      'price': 200,
      'description': 'A fiery red paddle skin.',
    });
    await db.insert('shop_items', {
      'name': 'Paddle: Ice',
      'type': 'paddle_skin',
      'price': 300,
      'description': 'A cool icy blue paddle skin.',
    });
    final ballStarId = await db.insert('shop_items', {
      'name': 'Ball: Star',
      'type': 'ball_skin',
      'price': 150,
      'description': 'A golden star ball.',
    });
    await db.insert('shop_items', {
      'name': 'Ball: Neon',
      'type': 'ball_skin',
      'price': 250,
      'description': 'A neon green glowing ball.',
    });
    await db.insert('shop_items', {
      'name': 'Life+',
      'type': 'life',
      'price': 500,
      'description': 'Permanently increases your max lives by 1.',
    });

    const hash =
        '1d707811988069ca760826861d6d63a10e8c3b7f171c4441a6472ea58c11711b';
    final now = DateTime.now().toIso8601String();

    final seedUsers = [
      ('alice@example.com', 'alice', 5200, 8, 4),
      ('bob@example.com', 'bob', 3100, 5, 3),
      ('carol@example.com', 'carol', 7800, 10, 4),
      ('dave@example.com', 'dave', 1200, 2, 3),
      ('eve@example.com', 'eve', 6500, 9, 3),
      ('frank@example.com', 'frank', 900, 1, 3),
      ('grace@example.com', 'grace', 4400, 7, 4),
      ('henry@example.com', 'henry', 2700, 4, 3),
      ('iris@example.com', 'iris', 8900, 10, 5),
      ('jack@example.com', 'jack', 600, 1, 3),
      ('kate@example.com', 'kate', 3800, 6, 3),
      ('leo@example.com', 'leo', 5100, 8, 4),
      ('mia@example.com', 'mia', 1700, 3, 3),
      ('noah@example.com', 'noah', 7200, 10, 4),
      ('olivia@example.com', 'olivia', 2200, 3, 3),
      ('peter@example.com', 'peter', 4900, 7, 3),
      ('quinn@example.com', 'quinn', 300, 0, 3),
      ('rose@example.com', 'rose', 6100, 9, 4),
      ('sam@example.com', 'sam', 1500, 2, 3),
      ('tina@example.com', 'tina', 9500, 10, 5),
    ];

    for (final u in seedUsers) {
      final uid = await db.insert('users', {
        'email': u.$1,
        'username': u.$2,
        'password_hash': hash,
        'coins': u.$3,
        'total_score': u.$3 * 10,
        'max_lives': u.$5,
        'created_at': now,
      });
      for (int s = 1; s <= u.$4; s++) {
        await db.insert('stage_results', {
          'user_id': uid,
          'stage_number': s,
          'score': s * 500 + u.$3 ~/ 10,
          'coins_earned': s * 50,
          'completed_at': now,
        });
      }
      if (u.$5 >= 4) {
        await db.insert('inventory', {
          'user_id': uid,
          'item_id': paddleFireId,
          'is_equipped': 1,
        });
      }
      if (u.$5 >= 5) {
        await db.insert('inventory', {
          'user_id': uid,
          'item_id': ballStarId,
          'is_equipped': 1,
        });
      }
    }
  }
}
