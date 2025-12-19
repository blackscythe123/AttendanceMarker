import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../core/theme.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We assume the state in provider is still valid/fresh right after save.
    // Alternatively, we could pass the session object.
    final provider = context.watch<AttendanceProvider>();
    final absentees = provider.absentRollNumbers.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Recorded')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'Successfully Saved!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total',
                      '${provider.totalStudents}',
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Present',
                      '${provider.presentCount}',
                      AppTheme.presentColor,
                    ),
                    _buildStatItem(
                      'Absent',
                      '${provider.absentCount}',
                      AppTheme.absentColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Absentees List
            if (absentees.isNotEmpty) ...[
              const Text(
                'Absent Roll Numbers:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    absentees
                        .map(
                          (roll) => Chip(
                            label: Text(
                              '$roll',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppTheme.absentColor,
                          ),
                        )
                        .toList(),
              ),
            ] else ...[
              const Text(
                'Full Attendance! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Pop back to dashboard (pop until first)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Return to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
