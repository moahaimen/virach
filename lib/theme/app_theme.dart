// lib/theme/app_themes.dart

import 'package:flutter/material.dart';

/// Light‐mode theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Cairo',
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Cairo'),
    displayMedium: TextStyle(fontFamily: 'Cairo'),
    displaySmall: TextStyle(fontFamily: 'Cairo'),
    headlineLarge: TextStyle(fontFamily: 'Cairo'),
    headlineMedium: TextStyle(fontFamily: 'Cairo'),
    headlineSmall: TextStyle(fontFamily: 'Cairo'),
    titleLarge: TextStyle(fontFamily: 'Cairo'),
    titleMedium: TextStyle(fontFamily: 'Cairo'),
    titleSmall: TextStyle(fontFamily: 'Cairo'),
    bodyLarge: TextStyle(fontFamily: 'Cairo'),
    bodyMedium: TextStyle(fontFamily: 'Cairo'),
    bodySmall: TextStyle(fontFamily: 'Cairo'),
    labelLarge: TextStyle(fontFamily: 'Cairo'),
    labelMedium: TextStyle(fontFamily: 'Cairo'),
    labelSmall: TextStyle(fontFamily: 'Cairo'),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.blue,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white70,
  ),
  iconTheme: const IconThemeData(color: Colors.teal),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white70,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.teal),
    ),
    labelStyle: TextStyle(color: Colors.black87),
    hintStyle: TextStyle(color: Colors.black45),
  ),
);

/// Dark‐mode theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Cairo',
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white60),
    labelLarge: TextStyle(color: Colors.white),
    labelMedium: TextStyle(color: Colors.white70),
    labelSmall: TextStyle(color: Colors.white54),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1A1A1A),
    selectedItemColor: Colors.tealAccent,
    unselectedItemColor: Colors.grey,
  ),
  iconTheme: const IconThemeData(color: Colors.tealAccent),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.tealAccent,
    foregroundColor: Colors.black,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.tealAccent,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1F1F1F),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white24),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.tealAccent),
    ),
    labelStyle: TextStyle(color: Colors.white70),
    hintStyle: TextStyle(color: Colors.white38),
  ),
);
