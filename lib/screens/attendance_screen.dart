import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../core/theme.dart';
import 'summary_screen.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final rollNumbers = List.generate(
      provider.totalStudents,
      (index) => index + 1,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(provider.selectedClass, style: const TextStyle(fontSize: 16)),
            Text(
              'Per: ${provider.selectedPeriod} • ${provider.presentCount} Present / ${provider.absentCount} Absent',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: 'Mark All Present',
            onPressed: () => provider.markAllPresent(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // 5 columns for compactness
                childAspectRatio: 1.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: rollNumbers.length,
              itemBuilder: (context, index) {
                final rollNo = rollNumbers[index];
                final isAbsent = provider.absentRollNumbers.contains(rollNo);

                return InkWell(
                  onTap: () => provider.toggleAttendance(rollNo),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isAbsent
                              ? AppTheme.absentColor
                              : AppTheme.presentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isAbsent
                                ? Colors.red.shade900
                                : Colors.green.shade700,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$rollNo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isAbsent ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await provider.saveAttendance();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SummaryScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'SAVE ATTENDANCE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
