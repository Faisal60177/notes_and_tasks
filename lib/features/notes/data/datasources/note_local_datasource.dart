import 'package:sqflite/sqflite.dart';
import 'package:NoteFlow/core/constants/owner_ids.dart';
import 'package:NoteFlow/core/database/database_helper.dart';
import '../models/note_model.dart';

class NoteLocalDatasource {
  NoteLocalDatasource({required this.ownerId});

  final String ownerId;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const _table = 'notes';

  Map<String, Object?> _row(NoteModel note) =>
      {...note.toSqliteMap(), 'ownerId': ownerId};

  Future<List<NoteModel>> getAllNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _table,
      where: 'ownerId = ? AND isDeleted = ?',
      whereArgs: [ownerId, 0],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map(NoteModel.fromSqliteMap).toList();
  }

  Future<List<NoteModel>> getUnsyncedNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _table,
      where: 'ownerId = ? AND isSynced = ?',
      whereArgs: [ownerId, 0],
    );
    return maps.map(NoteModel.fromSqliteMap).toList();
  }

  Future<List<NoteModel>> getAllNotesIncludingDeleted() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _table,
      where: 'ownerId = ?',
      whereArgs: [ownerId],
    );
    return maps.map(NoteModel.fromSqliteMap).toList();
  }

  Future<void> upsertNote(NoteModel note) async {
    final db = await _dbHelper.database;
    await db.insert(
      _table,
      _row(note),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertMany(List<NoteModel> notes) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final note in notes) {
      batch.insert(
        _table,
        _row(note),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> softDeleteNote(String id, DateTime updatedAt) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      {'isDeleted': 1, 'isSynced': 0, 'updatedAt': updatedAt.toIso8601String()},
      where: 'id = ? AND ownerId = ?',
      whereArgs: [id, ownerId],
    );
  }

  Future<void> restoreNote(String id, DateTime updatedAt) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      {'isDeleted': 0, 'isSynced': 0, 'updatedAt': updatedAt.toIso8601String()},
      where: 'id = ? AND ownerId = ?',
      whereArgs: [id, ownerId],
    );
  }

  Future<void> deleteNote(String id) async {
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