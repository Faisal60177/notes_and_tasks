import 'package:sqflite/sqflite.dart';
import 'package:notes_app/core/database/database_helper.dart';
import '../models/note_model.dart';

class NoteLocalDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<NoteModel>> getAllNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notes',
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((m) => NoteModel.fromSqliteMap(m)).toList();
  }

  Future<List<NoteModel>> getUnsyncedNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query('notes', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((m) => NoteModel.fromSqliteMap(m)).toList();
  }

  Future<void> upsertNote(NoteModel note) async {
    final db = await _dbHelper.database;
    await db.insert('notes', note.toSqliteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> upsertMany(List<NoteModel> notes) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final note in notes) {
      batch.insert('notes', note.toSqliteMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> softDeleteNote(String id, DateTime updatedAt) async {
    final db = await _dbHelper.database;
    await db.update(
      'notes',
      {'isDeleted': 1, 'isSynced': 0, 'updatedAt': updatedAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreNote(String id, DateTime updatedAt) async {
    final db = await _dbHelper.database;
    await db.update(
      'notes',
      {'isDeleted': 0, 'isSynced': 0, 'updatedAt': updatedAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> purgeSyncedDeletes() async {
    final db = await _dbHelper.database;
    await db.delete('notes', where: 'isDeleted = ? AND isSynced = ?', whereArgs: [1, 1]);
  }

  Future<void> markSynced(String id) async {
    final db = await _dbHelper.database;
    await db.update('notes', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }


}