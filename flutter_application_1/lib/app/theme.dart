import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get cyanDark {
    const cyanAccent = Color(0xFF00C8D7);
    const background = Color(0xFF121212);
    const surface = Color(0xFF181818);
    const textPrimary = Colors.white;
    const textSecondary = Color(0xFFB3B3B3);

    return ThemeData(
      useMaterial3: true,
      // brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: cyanAccent,
        onPrimary: Colors.black,
        secondary: cyanAccent,
        onSecondary: Colors.black,
        error: Colors.redAccent,
        onError: Colors.white,
        // background: background,
        // onBackground: textPrimary,
        surface: surface,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 24, 24, 24),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, 
        fillColor: background,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: Color(0xFF7A7A7A)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: cyanAccent),
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyanAccent,
          foregroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cyanAccent,
          foregroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
