import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  DbHelper._internal();
  factory DbHelper () => _instance;
  Database? _database;

  Future<Database> get database async{
    if(_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB()async{
    String dbPath = await getDatabasesPath();
    String path= join(dbPath, 'notes_app.db');
    return await openDatabase(path,
    version: 1,
      onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE notes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      color INTEGER NOT NULL, 
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
     
      )
      ''');

      await db.execute('''
        CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        isDone INTEGER NULL DEFAULT 0,
        priority INTEGER NULL DEFAULT 2,
        dueDate TEXT,
        createdAt TEXT NOT NULL,
        )
      ''');

      },
    );
  }




}