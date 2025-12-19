import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../repositories/attendance_repository.dart';
import '../models/attendance_session.dart';
import '../core/timetable_data.dart';
import '../core/theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AttendanceRepository _repo = AttendanceRepository();
  String _selectedClass = TimetableData.className;
  final List<String> _classes = [TimetableData.className];

  bool _isLoading = true;
  List<AttendanceSession> _sessions = [];
  Map<int, int> _studentAbsences = {}; // RollNo -> Count
  int _totalSessions = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final sessions = await _repo.getSessionsByClass(_selectedClass);

    // Calculate Stats
    final absenceCounts = <int, int>{};
    for (var s in sessions) {
      for (var roll in s.absentRollNumbers) {
        absenceCounts[roll] = (absenceCounts[roll] ?? 0) + 1;
      }
    }

    if (mounted) {
      setState(() {
        _sessions = sessions;
        _totalSessions = sessions.length;
        _studentAbsences = absenceCounts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Analytics')),
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
              items:
                  _classes
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  _selectedClass = val;
                  _loadData();
                }
              },
            ),
          ),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_sessions.isEmpty)
            const Expanded(
              child: Center(child: Text('No data found for this class.')),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Total Sessions',
                          '$_totalSessions',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInfoCard(
                          'Avg Attendance',
                          '${_calculateAvgAttendance()}%',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Chart: Attendance Trend (Last 7 sessions)
                  const Text(
                    'Attendance Trend (Present Count)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: _getChartData(),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                return Text(
                                  'S${val.toInt() + 1}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Most Absent Students
                  const Text(
                    'Most Absent Students (Risk List)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildRiskList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _calculateAvgAttendance() {
    if (_totalSessions == 0) return '0';
    int totalPossible = _totalSessions * 66; // 66 students
    int totalAbsences = _studentAbsences.values.fold(
      0,
      (sum, count) => sum + count,
    );
    int totalPresent = totalPossible - totalAbsences;
    return ((totalPresent / totalPossible) * 100).toStringAsFixed(1);
  }

  List<BarChartGroupData> _getChartData() {
    // Take last 7 sessions
    final recentSessions = _sessions.take(7).toList().reversed.toList();
    return List.generate(recentSessions.length, (index) {
      final session = recentSessions[index];
      final presentCount = 66 - session.absentRollNumbers.length;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: presentCount.toDouble(),
            color: AppTheme.primaryColor,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  List<Widget> _buildRiskList() {
    // Sort by most absences
    final sortedAbsences =
        _studentAbsences.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5
    return sortedAbsences.take(5).map((e) {
      final percentage = ((_totalSessions - e.value) / _totalSessions * 100)
          .toStringAsFixed(0);
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.absentColor,
            child: Text(
              '${e.key}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text('Roll Number ${e.key}'),
          subtitle: Text('Absent: ${e.value} sessions'),
          trailing: Text(
            '$percentage%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();
  }
}
