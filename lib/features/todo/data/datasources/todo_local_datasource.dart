import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/owner_ids.dart';
import '../../../../core/database/database_helper.dart';
import '../models/todo_model.dart';

class TodoLocalDatasource {
  TodoLocalDatasource({required this.ownerId});

  final String ownerId;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const _table = 'todos';

  Map<String, Object?> _row(TodoModel todo) =>
      {...todo.toSqfliteMap(), 'ownerId': ownerId};

  Future<List<TodoModel>> getAllTodos() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _table,
      where: 'ownerId = ? AND isDeleted = ?',
      whereArgs: [ownerId, 0],
      orderBy: 'createdAt DESC',
    );
    return maps.map(TodoModel.fromSqliteMap).toList();
  }

  Future<List<TodoModel>> getUnsyncedTodos() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _table,
      where: 'ownerId = ? AND isSynced = ?',
      whereArgs: [ownerId, 0],
    );
    return maps.map(TodoModel.fromSqliteMap).toList();
  }

  Future<List<TodoModel>> getAllTodosIncludingDeleted() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _table,
      where: 'ownerId = ?',
      whereArgs: [ownerId],
    );
    return maps.map(TodoModel.fromSqliteMap).toList();
  }

  Future<void> upsertTodo(TodoModel todo) async {
    final db = await _dbHelper.database;
    await db.insert(
      _table,
      _row(todo),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertMany(List<TodoModel> todos) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final todo in todos) {
      batch.insert(
        _table,
        _row(todo),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> softDeleteTodo(String id, DateTime updatedAt) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      {'isDeleted': 1, 'isSynced': 0, 'updatedAt': updatedAt.toIso8601String()},
      where: 'id = ? AND ownerId = ?',
      whereArgs: [id, ownerId],
    );
  }

  Future<void> restoreTodo(String id, DateTime updatedAt) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      {'isDeleted': 0, 'isSynced': 0, 'updatedAt': updatedAt.toIso8601String()},
      where: 'id = ? AND ownerId = ?',
      whereArgs: [id, ownerId],
    );
  }

  Future<void> deleteTodo(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      _table,
      where: 'id = ? AND ownerId = ?',
      whereArgs: [id, ownerId],
    );
  }

  Future<void> purgeSyncedDeletes() async {
    final db = await _dbHelper.database;
    await db.delete(
      _table,
      where: 'ownerId = ? AND isDeleted = ? AND isSynced = ?',
      whereArgs: [ownerId, 1, 1],
    );
  }

  Future<void> markSynced(String id, DateTime updatedAt) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      {'isSynced': 1},
      where: 'id = ? AND ownerId = ? AND updatedAt = ?',
      whereArgs: [id, ownerId, updatedAt.toIso8601String()],
    );
  }

  Future<void> adoptGuestRows() async {
    if (ownerId == kGuestOwnerId) return;
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        _table,
        where: 'ownerId = ? AND isDeleted = 1',
        whereArgs: [kGuestOwnerId],
      );
      await txn.update(
        _table,
        {'ownerId': ownerId, 'isSynced': 0},
        where: 'ownerId = ?',
        whereArgs: [kGuestOwnerId],
      );
    });
  }
}