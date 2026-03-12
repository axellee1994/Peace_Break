import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/stage_result.dart';
import '../models/shop_item.dart';
import '../models/inventory_item.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'peace_break.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
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
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        is_equipped INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (item_id) REFERENCES shop_items(id)
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

    await SeedData.seed(db);
  }

  // ==================== USER OPERATIONS ====================

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<bool> isEmailTaken(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return maps.isNotEmpty;
  }

  Future<bool> isUsernameTaken(String username) async {
    final db = await database;
    final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
    return maps.isNotEmpty;
  }

  Future<void> updateUserCoins(int userId, int coins) async {
    final db = await database;
    await db.update('users', {'coins': coins}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> updateUserTotalScore(int userId, int totalScore) async {
    final db = await database;
    await db.update('users', {'total_score': totalScore}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> updateUserMaxLives(int userId, int maxLives) async {
    final db = await database;
    await db.update('users', {'max_lives': maxLives}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> updateUserPassword(int userId, String passwordHash) async {
    final db = await database;
    await db.update('users', {'password_hash': passwordHash}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> updateUsername(int userId, String username) async {
    final db = await database;
    await db.update('users', {'username': username}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> resetUserProgress(int userId) async {
    final db = await database;
    await db.update(
      'users',
      {'coins': 0, 'total_score': 0, 'max_lives': 3},
      where: 'id = ?',
      whereArgs: [userId],
    );
    await db.delete('stage_results', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('inventory', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete('stage_results', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('inventory', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<List<User>> getTopUsers(int limit) async {
    final db = await database;
    final maps = await db.query(
      'users',
      orderBy: 'total_score DESC',
      limit: limit,
    );
    return maps.map((m) => User.fromMap(m)).toList();
  }

  // ==================== STAGE RESULT OPERATIONS ====================

  Future<void> saveStageResult(StageResult result) async {
    final db = await database;
    final existing = await db.query(
      'stage_results',
      where: 'user_id = ? AND stage_number = ?',
      whereArgs: [result.userId, result.stageNumber],
    );
    if (existing.isEmpty) {
      await db.insert('stage_results', result.toMap());
    } else {
      final oldScore = existing.first['score'] as int;
      if (result.score > oldScore) {
        await db.update(
          'stage_results',
          {'score': result.score, 'coins_earned': result.coinsEarned, 'completed_at': result.completedAt},
          where: 'user_id = ? AND stage_number = ?',
          whereArgs: [result.userId, result.stageNumber],
        );
      }
    }
  }

  Future<List<StageResult>> getStageResultsForUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'stage_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'stage_number ASC',
    );
    return maps.map((m) => StageResult.fromMap(m)).toList();
  }

  Future<StageResult?> getStageResult(int userId, int stageNumber) async {
    final db = await database;
    final maps = await db.query(
      'stage_results',
      where: 'user_id = ? AND stage_number = ?',
      whereArgs: [userId, stageNumber],
    );
    if (maps.isEmpty) return null;
    return StageResult.fromMap(maps.first);
  }

  Future<int> getMaxCompletedStage(int userId) async {
    final db = await database;
    final maps = await db.query(
      'stage_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'stage_number DESC',
      limit: 1,
    );
    if (maps.isEmpty) return 0;
    return maps.first['stage_number'] as int;
  }

  // ==================== SHOP ITEM OPERATIONS ====================

  Future<List<ShopItem>> getAllShopItems() async {
    final db = await database;
    final maps = await db.query('shop_items', orderBy: 'id ASC');
    return maps.map((m) => ShopItem.fromMap(m)).toList();
  }

  Future<ShopItem?> getShopItem(int id) async {
    final db = await database;
    final maps = await db.query('shop_items', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ShopItem.fromMap(maps.first);
  }

  // ==================== INVENTORY OPERATIONS ====================

  Future<void> addToInventory(int userId, int itemId) async {
    final db = await database;
    await db.insert('inventory', {
      'user_id': userId,
      'item_id': itemId,
      'is_equipped': 0,
    });
  }

  Future<bool> userOwnsItem(int userId, int itemId) async {
    final db = await database;
    final maps = await db.query(
      'inventory',
      where: 'user_id = ? AND item_id = ?',
      whereArgs: [userId, itemId],
    );
    return maps.isNotEmpty;
  }

  Future<List<InventoryItem>> getUserInventory(int userId) async {
    final db = await database;
    final maps = await db.query(
      'inventory',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((m) => InventoryItem.fromMap(m)).toList();
  }

  Future<void> equipItem(int userId, int itemId, String itemType) async {
    final db = await database;
    // Get item type to unequip others of same type
    final shopMaps = await db.query('shop_items', where: 'id = ?', whereArgs: [itemId]);
    if (shopMaps.isNotEmpty) {
      final type = shopMaps.first['type'] as String;
      // Unequip all items of same type for this user
      final inventoryMaps = await db.query(
        'inventory',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      for (final inv in inventoryMaps) {
        final invItemId = inv['item_id'] as int;
        final shopItemMaps = await db.query('shop_items', where: 'id = ?', whereArgs: [invItemId]);
        if (shopItemMaps.isNotEmpty && shopItemMaps.first['type'] == type) {
          await db.update(
            'inventory',
            {'is_equipped': 0},
            where: 'user_id = ? AND item_id = ?',
            whereArgs: [userId, invItemId],
          );
        }
      }
    }
    // Equip chosen item
    await db.update(
      'inventory',
      {'is_equipped': 1},
      where: 'user_id = ? AND item_id = ?',
      whereArgs: [userId, itemId],
    );
  }

  Future<void> unequipItem(int userId, int itemId) async {
    final db = await database;
    await db.update(
      'inventory',
      {'is_equipped': 0},
      where: 'user_id = ? AND item_id = ?',
      whereArgs: [userId, itemId],
    );
  }
}
