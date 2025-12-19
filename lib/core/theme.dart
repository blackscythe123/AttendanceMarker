import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color absentColor = Color(0xFFCF6679); // Red-ish
  static const Color presentColor = Color(0xFF4CAF50); // Green
  static const Color background = Color(0xFFF5F5F5);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      background: background,
      error: absentColor,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
