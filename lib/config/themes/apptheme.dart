import 'package:flutter/material.dart';

ThemeData omnichordAppTheme(){
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF191414),
    colorScheme: const ColorScheme.dark(
    primary: Color(0xFF1DB954),
    secondary: Color(0xFF1ED760),
    surface: Color(0xFF121212),
  ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFB3B3B3)),
  ),

  );
}