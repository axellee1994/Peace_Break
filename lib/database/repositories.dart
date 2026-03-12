import 'package:sqflite/sqflite.dart';
import 'orm.dart';
import '../models/user.dart';
import '../models/stage_result.dart';
import '../models/shop_item.dart';
import '../models/inventory_item.dart';

class UserRepository extends Repository<User> {
  UserRepository(super.db);

  @override
  String get tableName => 'users';

  @override
  User fromMap(Map<String, dynamic> map) => User.fromMap(map);

  Future<User?> findByUsernameOrEmail(String identifier) => findOne(
        where: 'username = ? OR email = ?',
        whereArgs: [identifier, identifier],
      );

  Future<bool> isEmailTaken(String email) async =>
      await count(where: 'email = ?', whereArgs: [email]) > 0;

  Future<bool> isUsernameTaken(String username) async =>
      await count(where: 'username = ?', whereArgs: [username]) > 0;

  Future<List<User>> topByScore(int limit) => findAll(
        orderBy: 'total_score DESC',
        limit: limit,
      );

  Future<int> rankOf(int userId) async {
    final user = await findById(userId);
    if (user == null) return -1;
    final above = await count(
      where: 'total_score > ?',
      whereArgs: [user.totalScore],
    );
    return above + 1;
  }
}

class StageResultRepository extends Repository<StageResult> {
  StageResultRepository(super.db);

  @override
  String get tableName => 'stage_results';

  @override
  StageResult fromMap(Map<String, dynamic> map) => StageResult.fromMap(map);

  Future<List<StageResult>> forUser(int userId) => findAll(
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'stage_number ASC',
      );

  Future<StageResult?> forUserAndStage(int userId, int stageNumber) => findOne(
        where: 'user_id = ? AND stage_number = ?',
        whereArgs: [userId, stageNumber],
      );

  Future<void> upsertBest({
    required int userId,
    required int stageNumber,
    required int score,
    required int coinsEarned,
  }) async {
    final existing = await forUserAndStage(userId, stageNumber);
    if (existing == null) {
      await insert(StageResult(
        userId: userId,
        stageNumber: stageNumber,
        score: score,
        coinsEarned: coinsEarned,
        completedAt: DateTime.now().toIso8601String(),
      ));
    } else if (score > existing.score) {
      await updateFields(existing.id!, {
        'score': score,
        'coins_earned': coinsEarned,
        'completed_at': DateTime.now().toIso8601String(),
      });
    }
  }
}

class ShopItemRepository extends Repository<ShopItem> {
  ShopItemRepository(super.db);

  @override
  String get tableName => 'shop_items';

  @override
  ShopItem fromMap(Map<String, dynamic> map) => ShopItem.fromMap(map);
}

class InventoryItemRepository extends Repository<InventoryItem> {
  InventoryItemRepository(super.db);

  @override
  String get tableName => 'inventory';

  @override
  InventoryItem fromMap(Map<String, dynamic> map) =>
      InventoryItem.fromMap(map);

  Future<List<InventoryItem>> forUser(int userId) => findAll(
        where: 'user_id = ?',
        whereArgs: [userId],
      );

  Future<bool> userOwnsItem(int userId, int itemId) async =>
      await count(
        where: 'user_id = ? AND item_id = ?',
        whereArgs: [userId, itemId],
      ) >
      0;

  Future<void> equipExclusive(
      int userId, int itemId, Database db) async {
    final rows = await db.rawQuery('''
      SELECT i.id, s.type
      FROM inventory i
      JOIN shop_items s ON s.id = i.item_id
      WHERE i.user_id = ?
    ''', [userId]);

    final targetRows = await db.rawQuery(
      'SELECT type FROM shop_items WHERE id = ?',
      [itemId],
    );
    if (targetRows.isEmpty) return;
    final type = targetRows.first['type'] as String;

    for (final row in rows) {
      if (row['type'] == type) {
        await db.update(
          'inventory',
          {'is_equipped': 0},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }

    await updateWhere(
      fields: {'is_equipped': 1},
      where: 'user_id = ? AND item_id = ?',
      whereArgs: [userId, itemId],
    );
  }

  Future<void> unequip(int userId, int itemId) => updateWhere(
        fields: {'is_equipped': 0},
        where: 'user_id = ? AND item_id = ?',
        whereArgs: [userId, itemId],
      );
}
