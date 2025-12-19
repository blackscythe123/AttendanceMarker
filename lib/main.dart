import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/attendance_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure DB is ready? Actually DatabaseHelper inits on first access.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AttendanceProvider())],
      child: MaterialApp(
        title: 'Offline Attendance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}
