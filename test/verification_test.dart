import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:AttendanceMarker/repositories/attendance_repository.dart';
import 'package:AttendanceMarker/models/attendance_session.dart';
import 'package:AttendanceMarker/core/database_helper.dart';

void main() {
  // Setup sqflite_common_ffi for testing on Windows/Desktop without emulator
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // We need to override the default instance path or just rely on ffi using in-memory or local file
  // Since DatabaseHelper uses `getDatabasesPath`, we might need to mock it or let it write to disk.
  // For simplicity, we just test the Repository logic if we can inject DB, but our Helper is a singleton.
  // FFI usually works for integration tests.

  test('Database Integration Test', () async {
    final repo = AttendanceRepository();

    // 1. Save a session
    final session = AttendanceSession(
      date: '2023-10-27',
      className: 'Class 10-A',
      period: 1,
      timestamp: 123456789,
      absentRollNumbers: [4, 12, 23],
    );

    print('Saving Session...');
    await repo.saveSession(session);
    print('Session Saved.');

    // 2. Retrieve it
    print('Retrieving Session...');
    final loaded = await repo.getSession('2023-10-27', 'Class 10-A', 1);

    expect(loaded, isNotNull);
    expect(loaded!.absentRollNumbers.length, 3);
    expect(loaded.absentRollNumbers, contains(4));
    print('Session Retrieved: ${loaded.absentRollNumbers} Absentees');

    // 3. Test Analytics Fetch
    print('Fetching Class Sessions...');
    final sessions = await repo.getSessionsByClass('Class 10-A');
    expect(sessions.length, greaterThanOrEqualTo(1));
    print('Found ${sessions.length} sessions for Class 10-A');
  });
}
