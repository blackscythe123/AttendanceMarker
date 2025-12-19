import 'package:sqflite/sqflite.dart';
import '../core/database_helper.dart';

class TimetableRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveOverride({
    required String date,
    required int period,
    required String className,
    required String newSubject,
  }) async {
    final db = await _dbHelper.database;
    await db.insert('timetable_changes', {
      'date': date,
      'period': period,
      'className': className,
      'newSubject': newSubject,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getOverride({
    required String date,
    required int period,
    required String className,
  }) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'timetable_changes',
      where: 'date = ? AND period = ? AND className = ?',
      whereArgs: [date, period, className],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['newSubject'] as String;
    }
    return null;
  }
}
