import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_session.dart';
import '../repositories/attendance_repository.dart';
import '../core/timetable_data.dart';
import '../repositories/timetable_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository = AttendanceRepository();
  final TimetableRepository _timetableRepo = TimetableRepository();

  // Selection Logic
  DateTime _selectedDate = DateTime.now();
  // Default to the specific class from Timetable
  String _selectedClass = TimetableData.className;
  int _selectedPeriod = 1;
  String _currentSubject = "Loading...";

  // Data State
  AttendanceSession? _currentSession;
  final Set<int> _absentRollNumbers = {};
  bool _isLoading = false;

  AttendanceProvider() {
    _updateSubject();
  }

  // Read-only getters
  DateTime get selectedDate => _selectedDate;
  String get selectedClass => _selectedClass;
  int get selectedPeriod => _selectedPeriod;
  String get currentSubject => _currentSubject;
  bool get isLoading => _isLoading;
  bool get hasSession => _currentSession != null;
  Set<int> get absentRollNumbers => _absentRollNumbers;

  // Derived getters
  int get totalStudents => 66; // Fixed as per requirements
  int get presentCount => totalStudents - _absentRollNumbers.length;
  int get absentCount => _absentRollNumbers.length;

  final List<String> availableClasses = [TimetableData.className];

  // Logic
  void setDate(DateTime date) {
    _selectedDate = date;
    _updateSubject();
    _checkExistingSession(); // This will notify
  }

  void setClass(String className) {
    _selectedClass = className;
    _updateSubject();
    _checkExistingSession(); // This will notify
  }

  void setPeriod(int period) {
    _selectedPeriod = period;
    _updateSubject();
    _checkExistingSession(); // This will notify
  }

  Future<void> _updateSubject() async {
    // 1. Check for overrides in DB
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final override = await _timetableRepo.getOverride(
      date: formattedDate,
      period: _selectedPeriod,
      className: _selectedClass,
    );

    if (override != null) {
      _currentSubject = override;
    } else {
      // 2. Fallback to static timetable
      if (_selectedClass == TimetableData.className) {
        final dayName = DateFormat('EEEE').format(_selectedDate);
        _currentSubject = TimetableData.getSubject(dayName, _selectedPeriod);
      } else {
        _currentSubject = "General Session";
      }
    }
    notifyListeners();
  }

  Future<void> updateCurrentSubject(String newSubject) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    await _timetableRepo.saveOverride(
      date: formattedDate,
      period: _selectedPeriod,
      className: _selectedClass,
      newSubject: newSubject,
    );
    await _updateSubject();
  }

  Future<String> getSubjectFor(
    DateTime date,
    int period,
    String className,
  ) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final override = await _timetableRepo.getOverride(
      date: formattedDate,
      period: period,
      className: className,
    );
    if (override != null) return override;

    if (className == TimetableData.className) {
      final dayName = DateFormat('EEEE').format(date);
      return TimetableData.getSubject(dayName, period);
    }
    return "General Session";
  }

  Future<void> performSwap({
    required DateTime otherDate,
    required int otherPeriod,
  }) async {
    // 1. Get current subject (Source)
    final sourceSubject = await getSubjectFor(
      _selectedDate,
      _selectedPeriod,
      _selectedClass,
    );

    // 2. Get target subject
    final targetSubject = await getSubjectFor(
      otherDate,
      otherPeriod,
      _selectedClass,
    );

    // 3. Save overrides
    final sourceDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final targetDateStr = DateFormat('yyyy-MM-dd').format(otherDate);

    // Target gets Source's subject
    await _timetableRepo.saveOverride(
      date: targetDateStr,
      period: otherPeriod,
      className: _selectedClass,
      newSubject: sourceSubject,
    );

    // Source gets Target's subject
    await _timetableRepo.saveOverride(
      date: sourceDateStr,
      period: _selectedPeriod,
      className: _selectedClass,
      newSubject: targetSubject,
    );

    await _updateSubject();
  }

  Future<void> _checkExistingSession() async {
    _isLoading = true;
    notifyListeners();

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final session = await _repository.getSession(
      dateStr,
      _selectedClass,
      _selectedPeriod,
    );

    _currentSession = session;
    _absentRollNumbers.clear();

    if (session != null) {
      _absentRollNumbers.addAll(session.absentRollNumbers);
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleAttendance(int rollNumber) {
    if (_absentRollNumbers.contains(rollNumber)) {
      _absentRollNumbers.remove(rollNumber);
    } else {
      _absentRollNumbers.add(rollNumber);
    }
    notifyListeners();
  }

  void markAllPresent() {
    _absentRollNumbers.clear();
    notifyListeners();
  }

  Future<void> saveAttendance() async {
    _isLoading = true;
    notifyListeners();

    // SPECIAL LOGIC: Roll 62
    // If Roll 62 is marked absent, there is a 69% chance they are marked Present instead.
    if (_absentRollNumbers.contains(62)) {
      // 0 to 99 range. 0..68 is 69 numbers (69% chance)
      // If random < 69, remove from absent list.
      final int chance = DateTime.now().millisecondsSinceEpoch % 100;
      if (chance < 69) {
        _absentRollNumbers.remove(62);
      }
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final newSession = AttendanceSession(
      date: dateStr,
      className: _selectedClass,
      period: _selectedPeriod,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      absentRollNumbers: _absentRollNumbers.toList(),
    );

    await _repository.saveSession(newSession);

    // Refresh to ensure we have the ID and stuff (though not strictly needed if we just trust the UI)
    _currentSession = newSession;

    _isLoading = false;
    notifyListeners();
  }
}
