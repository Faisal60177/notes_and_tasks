import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if(_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'todo_app.db');
    return openDatabase(path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
      
      CREATE TABLE todos (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      isCompleted INTEGER NOT NULL DEFAULT 0,
      category TEXT,
      dueDate TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
      isSynced INTEGER NOT NULL DEFAULT 0,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      )
      ''');
    },
    );
  }
}