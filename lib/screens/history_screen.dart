import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/attendance_repository.dart';
import '../models/attendance_session.dart';
import '../core/timetable_data.dart';
import '../core/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  final AttendanceRepository  = AttendanceRepository();
  bool _isLoading = false;
  List<AttendanceSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // We need a method to get sessions by DATE (across all classes)
    // Currently repo only has getSession(date, class, period) or getSessionsByClass(class)
    // We should probably add `getSessionsByDate` to repo.
    // For now, I'll cheat and fetch all sessions for known classes and filter in memory or add the query method.
    // Let's add the query method to repository in next step. For known classes:
    final allClasses = [TimetableData.className];
    List<AttendanceSession> allSessions = [];

    for (var cls in allClasses) {
      // Inefficient but works with current repo API: loop periods 1-8
      for (int p = 1; p <= 8; p++) {
        final s = await _repo.getSession(dateStr, cls, p);
        if (s != null) allSessions.add(s);
      }
    }

    // Sort by time
    allSessions.sort(
      (a, b) => b.period.compareTo(a.period),
    ); // Period descending? or Ascending? Let's do Ascending.
    allSessions.sort((a, b) => a.period.compareTo(b.period));

    if (mounted) {
      setState(() {
        _sessions = allSessions;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: InkWell(
              onTap: _pickDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _sessions.isEmpty
                    ? const Center(
                      child: Text(
                        'No records found for this date.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _sessions.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final presentCount =
                            66 - session.absentRollNumbers.length;
                        return Card(
                          child: ExpansionTile(
                            title: Text(
                              '${session.className} - Period ${session.period}',
                            ),
                            subtitle: Text('Present: $presentCount / 66'),
                            trailing: Icon(
                              Icons.circle,
                              color:
                                  session.absentRollNumbers.isEmpty
                                      ? Colors.green
                                      : Colors.orange,
                              size: 12,
                            ),
                            children: [
                              if (session.absentRollNumbers.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Absentees:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children:
                                            session.absentRollNumbers
                                                .map(
                                                  (r) => Chip(
                                                    label: Text('$r'),
                                                    backgroundColor: AppTheme
                                                        .absentColor
                                                        .withOpacity(0.2),
                                                    labelStyle: const TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Full Attendance',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
