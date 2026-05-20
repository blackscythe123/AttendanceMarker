import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import 'attendance_screen.dart';
import 'analytics_screen.dart';
import 'history_screen.dart';
import '../core/timetable_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize provider check mainly if we want to pre-load something
    Future.microtask(
      () => context.read<AttendanceProvider>().setDate(DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Selection Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  DateFormat('EEEE, MMM d, yyyy').format(provider.selectedDate),
                ),
                subtitle: const Text('Tap to change date'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: provider.selectedDate,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    provider.setDate(picked);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Class Selection
            const Text(
              'Select Class',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: provider.selectedClass,
                    items:
                        provider.availableClasses.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) provider.setClass(newValue);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Period Selection
            const Text(
              'Select Period',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: provider.selectedPeriod,
                    items:
                        List.generate(8, (index) => index + 1).map((int value) {
                          // Get Timing from TimetableData (import missing but we can hardcode for now or fix import)
                          // Actually better to fix main.dart or pass it via provider/static.
                          // Since we didn't export TimetableData here, let's use the provider if possible or just import.
                          // However, provider doesn't expose times.
                          // Quick fix: Hardcode map here or import. Let's Import.
                          final time = TimetableData.periodTimes[value] ?? "";
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('Period $value ($time)'),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) provider.setPeriod(newValue);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subject Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Subject',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          provider.currentSubject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit Button
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: "Edit Subject",
                    onPressed: () => _showEditSubjectDialog(context),
                  ),
                  // Swap Button
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.orange),
                    tooltip: "Swap Period",
                    onPressed: () => _showSwapPeriodDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Button
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                icon: Icon(
                  provider.hasSession ? Icons.edit : Icons.check_circle_outline,
                ),
                label: Text(
                  provider.hasSession ? 'Edit Attendance' : 'Take Attendance',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      provider.hasSession
                          ? Colors.orange
                          : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                  );
                },
              ),

            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('View Analytics'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('View History By Date'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSubjectDialog(BuildContext context) async {
    final provider = context.read<AttendanceProvider>();
    final controller = TextEditingController(text: provider.currentSubject);

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Edit Subject Name"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "New Subject Name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    await provider.updateCurrentSubject(controller.text);
                    if (mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  Future<void> _showSwapPeriodDialog(BuildContext context) async {
    final provider = context.read<AttendanceProvider>();
    // Default to current date but different period
    DateTime selectedDate = provider.selectedDate;
    int selectedPeriod = 1;

    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Swap Period With..."),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: selectedPeriod,
                      items:
                          List.generate(8, (i) => i + 1)
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text("Period $p"),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedPeriod = val);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await provider.performSwap(
                        otherDate: selectedDate,
                        otherPeriod: selectedPeriod,
                      );
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: const Text("Swap"),
                  ),
                ],
              );
            },
          ),
    );
  }
}
