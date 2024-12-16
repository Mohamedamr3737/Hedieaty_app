import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    print(dbPath);
    final path = join(dbPath, 'user_database121.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }


  // Future<void> _onCreate(Database db, int version) async {
  //   await db.execute('''
  //   CREATE TABLE Users (
  //     id INTEGER PRIMARY KEY AUTOINCREMENT,
  //     uid TEXT NULL,
  //     name TEXT NOT NULL,
  //     email TEXT NOT NULL UNIQUE,
  //     mobile TEXT NOT NULL UNIQUE,
  //     preferences TEXT
  //   );
  //
  //   CREATE TABLE Events (
  //     id INTEGER PRIMARY KEY AUTOINCREMENT,
  //     name TEXT NOT NULL,
  //     date TEXT NOT NULL,
  //     location TEXT NOT NULL,
  //     description TEXT,
  //     category Text,
  //     published INTEGER NOT NULL CHECK (published IN (0, 1)),
  //     user_id INTEGER NOT NULL,
  //     FOREIGN KEY (user_id) REFERENCES Users (uid) ON DELETE CASCADE
  //   );
  //
  //   CREATE TABLE Gifts (
  //     id INTEGER PRIMARY KEY AUTOINCREMENT,
  //     name TEXT NOT NULL,
  //     description TEXT,
  //     category TEXT NOT NULL,
  //     price REAL NOT NULL,
  //     status TEXT NOT NULL,
  //     published INTEGER NOT NULL CHECK (published IN (0, 1)),
  //     event_id INTEGER NOT NULL,
  //     FOREIGN KEY (event_id) REFERENCES Events (id) ON DELETE CASCADE
  //   );
  //
  //   CREATE TABLE Friends (
  //     user_id INTEGER NOT NULL,
  //     friend_id INTEGER NOT NULL,
  //     PRIMARY KEY (user_id, friend_id),
  //     FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE,
  //   );
  // ''');
  // }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Users (
      uid TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      mobile TEXT NOT NULL UNIQUE,
      preferences TEXT
    );
  ''');

    await db.execute('''
    CREATE TABLE Events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      date TEXT NOT NULL,
      location TEXT NOT NULL,
      description TEXT,
      category TEXT,
      published INTEGER NOT NULL CHECK (published IN (0, 1)),
      user_id text NOT NULL,
      firestore_id TEXT UNIQUE,
      FOREIGN KEY (user_id) REFERENCES Users (uid) ON DELETE CASCADE
    );
  ''');

    await db.execute('''
    CREATE TABLE Gifts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT NOT NULL,
      price REAL NOT NULL,
      status TEXT NOT NULL,
      published INTEGER NOT NULL CHECK (published IN (0, 1)),
      event_id Text NOT NULL,
      firestoreId Text,
      imageLink Text,
      FOREIGN KEY (event_id) REFERENCES Events (firestore_id) ON DELETE CASCADE
    );
  ''');

    await db.execute('''
    CREATE TABLE Friends (
      user_id Text NOT NULL,
      friend_id INTEGER NOT NULL,
      PRIMARY KEY (user_id, friend_id),
      FOREIGN KEY (user_id) REFERENCES Users (uid) ON DELETE CASCADE
    );
  ''');
  }


  // uid TEXT NULL,
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
