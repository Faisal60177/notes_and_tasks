import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/todo_model.dart';

class TodoLocalDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<TodoModel>> getAllTodos() async {
    final db= await _dbHelper.database;
    final maps = await db.query(
      'todos',
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => TodoModel.fromSqfliteMap(m)).toList();
  }

  Future<List<TodoModel>> getUnsyncedTodos() async{
    final db = await _dbHelper.database;
    final maps = await db.query(
      'todos',
      where: 'isSynced = ?',
      whereArgs: [0]
    );
    return maps.map((m) => TodoModel.fromSqfliteMap(m)).toList();
  }

  Future<void> upsertTodo(TodoModel todo) async {
    final db = await _dbHelper.database;
    await db.insert(
      'todos',
    todo.toSqfliteMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertMany(List<TodoModel> todos) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for(final todo in todos){
      batch.insert('todos', todo.toSqfliteMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> softDeleteTodo(String id, DateTime updatedAt) async {
    final db = await _dbHelper.database;
    await db.update('todos',
        {
          'isDeleted' : 1,
          'isSynced' : 0,
          'updatedAt': updatedAt.toIso8601String(),
        },
        where:  'id =?',
        whereArgs: [id],
    );
  }

  Future<void> restoreTodo(String id, DateTime updatedAt) async {
    final db = await _dbHelper.database;
    await db.update(
      'todos',
      {'isDeleted': 0, 'isSynced': 0, 'updatedAt': updatedAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> purgeSyncedDeletes() async {
    final db = await _dbHelper.database;
    await db.delete('todos',
        where: 'isDeleted = ? AND isSynced = ?', whereArgs: [1, 1]);
  }

  Future<void> markSynced(String id) async {
    final db = await _dbHelper.database;
    await db.update('todos',
        {'isSynced': 1},
        where: 'id =? ',
        whereArgs: [id]
        );
  }
}