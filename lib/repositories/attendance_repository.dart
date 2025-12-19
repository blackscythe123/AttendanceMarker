import 'package:sqflite/sqflite.dart';
import '../core/database_helper.dart';
import '../models/attendance_session.dart';

class AttendanceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> saveSession(AttendanceSession session) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      // 1. Check if session already exists for this Class+Date+Period
      // Ideally we update it, or prevent duplicates. Let's assume update logic.
      // For simplicity, let's delete existing session if it matches (overwrite behavior)
      await txn.delete(
        'sessions',
        where: 'date = ? AND className = ? AND period = ?',
        whereArgs: [session.date, session.className, session.period],
      );

      // 2. Insert new Session
      final sessionId = await txn.insert('sessions', session.toMap());

      // 3. Insert Absences
      final batch = txn.batch();
      for (final rollNo in session.absentRollNumbers) {
        batch.insert('absences', {
          'sessionId': sessionId,
          'rollNumber': rollNo,
        });
      }
      await batch.commit(noResult: true);

      return sessionId;
    });
  }

  Future<AttendanceSession?> getSession(
    String date,
    String className,
    int period,
  ) async {
    final db = await _dbHelper.database;

    final sessions = await db.query(
      'sessions',
      where: 'date = ? AND className = ? AND period = ?',
      whereArgs: [date, className, period],
    );

    if (sessions.isEmpty) return null;

    final sessionData = sessions.first;
    final sessionId = sessionData['id'] as int;

    final absences = await db.query(
      'absences',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );

    final absentRolls = absences.map((e) => e['rollNumber'] as int).toList();

    return AttendanceSession.fromMap(sessionData, absentRolls);
  }

  Future<List<AttendanceSession>> getSessionsByClass(String className) async {
    final db = await _dbHelper.database;
    final sessions = await db.query(
      'sessions',
      where: 'className = ?',
      whereArgs: [className],
      orderBy: 'date DESC, period DESC',
    );

    List<AttendanceSession> result = [];
    for (var s in sessions) {
      final sessionId = s['id'] as int;
      final absences = await db.query(
        'absences',
        where: 'sessionId = ?',
        whereArgs: [sessionId],
      );
      final absentRolls = absences.map((e) => e['rollNumber'] as int).toList();
      result.add(AttendanceSession.fromMap(s, absentRolls));
    }
    return result;
  }
}
