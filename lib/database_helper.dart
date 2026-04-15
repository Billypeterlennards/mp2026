import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }

  // SIGNUP
  Future<bool> createUser(
      String username, String email, String password) async {
    try {
      final db = await instance.database;

      await db.insert(
        'users',
        {
          'username': username.trim(),
          'email': email.trim(),
          'password': password.trim(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return true;
    } catch (e) {
      print("Signup Error: $e");
      return false;
    }
  }

  // LOGIN
  Future<bool> loginUser(String username, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim(), password.trim()],
    );

    return result.isNotEmpty;
  }
}