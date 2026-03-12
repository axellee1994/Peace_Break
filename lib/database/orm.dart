import 'package:sqflite/sqflite.dart';

abstract class Model {
  int? get id;
  Map<String, dynamic> toMap();
}

abstract class Repository<T extends Model> {
  final Database db;

  Repository(this.db);

  String get tableName;
  T fromMap(Map<String, dynamic> map);

  Future<int> insert(T model) async {
    final map = model.toMap()..remove('id');
    return db.insert(tableName, map,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<T?> findById(int id) async {
    final rows =
        await db.query(tableName, where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : fromMap(rows.first);
  }

  Future<List<T>> findAll({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final rows = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
    return rows.map(fromMap).toList();
  }

  Future<T?> findOne({
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final rows = await db.query(tableName,
        where: where, whereArgs: whereArgs, limit: 1);
    return rows.isEmpty ? null : fromMap(rows.first);
  }

  Future<int> count({String? where, List<Object?>? whereArgs}) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM $tableName'
      '${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return result.first['c'] as int;
  }

  Future<int> update(T model) async {
    assert(model.id != null, 'Cannot update a model without an id');
    return db.update(tableName, model.toMap(),
        where: 'id = ?', whereArgs: [model.id]);
  }

  Future<int> updateFields(
    int id,
    Map<String, dynamic> fields,
  ) async {
    return db.update(tableName, fields, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWhere({
    required Map<String, dynamic> fields,
    required String where,
    required List<Object?> whereArgs,
  }) {
    return db.update(tableName, fields, where: where, whereArgs: whereArgs);
  }

  Future<int> deleteById(int id) =>
      db.delete(tableName, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteWhere(String where, List<Object?> whereArgs) =>
      db.delete(tableName, where: where, whereArgs: whereArgs);
}
