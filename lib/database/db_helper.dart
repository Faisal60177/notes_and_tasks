import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note_model.dart';
import '../models/todo_model.dart';

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

  // CREATE — new note to save in database
  Future<int> insertNote(NoteModel note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

// READ — all notes read and read the latest or first one

Future<List<NoteModel>> getAllNotes() async{
    final db= await database;
  // query() — SELECT * FROM notes ORDER BY id DESC like that
  final List<Map<String,dynamic>> maps = await db.query(
      'notes',
      orderBy: 'id DESC');
  return maps.map((map) => NoteModel.fromMap(map)).toList();
}

// READ — read only note with that id
Future<NoteModel?> getNoteById(int id) async{
    final db = await database;
    final maps = await db.query('notes', where: 'id= ?', whereArgs: [id],);
    if(maps.isEmpty) return null;
    return NoteModel.fromMap(maps.first);
}

Future<int> updateNote(NoteModel note) async{
    final db = await database;
    return await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id],);
}

Future<int> deleteNote(int id) async{
    final db = await database;
    return await db.delete(
      'notes', where: 'id= ?', whereArgs: [id],
    );
}

// SEARCH — search keyword in title or content
Future<List<NoteModel>> searchNotes(String keyword) async{
    final db = await database;
    final maps = await db.query('notes',
      // LIKE — partial match so used this %
      where: 'title LIKE ? OR content LIKE?',
      whereArgs: ['%$keyword%', '%$keyword'],
    );
    return maps.map((map) => NoteModel.fromMap(map)).toList();
}

// Now for TODOS  CRUD Operations

  Future<int> insertTodo(TodoModel todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  Future<List<TodoModel>> getAllTodos() async{
    final db = await database;
    final maps = await db.query('todos', orderBy: 'priority ASC, id DESC');
    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  Future<int> updateTodo(TodoModel todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }


  // for only toggle update no need to update whole object there
  Future<int> toggleTodoDone(int id, bool isDone) async {
    final db = await database;
    return await db.update(
      'todos',
      {'isDone': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TodoModel>> searchTodos(String keyword) async {
    final db = await database;
    final maps = await db.query(
      'todos',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

}