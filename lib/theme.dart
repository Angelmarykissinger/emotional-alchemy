import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFB39DDB); // Deep Purple 200
  static const Color secondaryColor = Color(0xFFF48FB1); // Pink 200
  static const Color backgroundColor = Color(0xFFF3E5F5); // Purple 50
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF9A9A); // Red 200
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF4A148C); // Purple 900
  static const Color onSurface = Color(0xFF424242);

  static final ThemeData pastelTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: onPrimary,
      secondary: secondaryColor,
      onSecondary: onSecondary,
      error: errorColor,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: onSurface,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: onPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(16),
      hintStyle: TextStyle(color: Colors.grey[400]),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: onBackground,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: onBackground,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      bodyLarge: TextStyle(
        color: onSurface,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: onSurface,
        fontSize: 14,
      ),
    ),
  );
}
