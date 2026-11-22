import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/owner_ids.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  static const int _dbVersion = 2;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'todo_app.db');
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTodosTable(db);
        await _createNotesTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          for (final table in ['todos', 'notes']) {
            await db.execute(
              "ALTER TABLE $table ADD COLUMN ownerId TEXT NOT NULL DEFAULT '$kGuestOwnerId'",
            );
            await db.execute('CREATE INDEX idx_${table}_owner ON $table(ownerId)');
          }
        }
      },
    );
  }

  Future<void> _createTodosTable(Database db) async {
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        ownerId TEXT NOT NULL DEFAULT '$kGuestOwnerId',
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        category TEXT,
        priority TEXT NOT NULL DEFAULT 'medium',
        dueDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_todos_owner ON todos(ownerId)');
  }

  Future<void> _createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        ownerId TEXT NOT NULL DEFAULT '$kGuestOwnerId',
        title TEXT NOT NULL,
        content TEXT,
        color TEXT NOT NULL DEFAULT 'default',
        category TEXT,
        isPinned INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_notes_owner ON notes(ownerId)');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}