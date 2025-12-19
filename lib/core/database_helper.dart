import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE timetable_changes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          period INTEGER NOT NULL,
          newSubject TEXT NOT NULL,
          className TEXT NOT NULL,
          UNIQUE(date, period, className)
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Session Table: Tracks a specific class period attendance event
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        className TEXT NOT NULL,
        period INTEGER NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    // Attendance Table: Tracks ONLY absences (sparse storage)
    // If a student is NOT in this table for a session, they are PRESENT.
    await db.execute('''
      CREATE TABLE absences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        rollNumber INTEGER NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    // Index for faster queries
    await db.execute(
      'CREATE INDEX idx_absences_session ON absences(sessionId);',
    );
    await db.execute('CREATE INDEX idx_sessions_class ON sessions(className);');

    // Timetable Changes Table: Stores overrides for specific date/period
    await db.execute('''
      CREATE TABLE timetable_changes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        period INTEGER NOT NULL,
        newSubject TEXT NOT NULL,
        className TEXT NOT NULL,
        UNIQUE(date, period, className)
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
