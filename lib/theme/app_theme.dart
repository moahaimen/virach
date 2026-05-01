import 'package:flutter/material.dart';

class RacheetaColors {
  const RacheetaColors._();

  static const Color primary = Color(0xFF17B3A3);
  static const Color primaryHover = Color(0xFF119C90);
  static const Color softMint = Color(0xFFA9D6CF);
  static const Color mintLight = Color(0xFFCFE5E1);
  static const Color surface = Color(0xFFF4F6F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3135);
  static const Color textSecondary = Color(0xFF7E8788);
  static const Color border = Color(0xFFDDE7E4);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  static const Color darkBackground = Color(0xFF0D1418);
  static const Color darkSurface = Color(0xFF111C22);
  static const Color darkCard = Color(0xFF16242B);
  static const Color darkBorder = Color(0xFF25333A);
  static const Color darkTextPrimary = Color(0xFFF3F7F6);
  static const Color darkTextSecondary = Color(0xFFA8B3B5);
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Cairo',
  scaffoldBackgroundColor: RacheetaColors.surface,
  cardColor: RacheetaColors.card,
  colorScheme: ColorScheme.fromSeed(
    seedColor: RacheetaColors.primary,
    brightness: Brightness.light,
    primary: RacheetaColors.primary,
    secondary: RacheetaColors.primaryHover,
    surface: RacheetaColors.card,
    error: RacheetaColors.danger,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: RacheetaColors.card,
    foregroundColor: RacheetaColors.textPrimary,
    iconTheme: IconThemeData(color: RacheetaColors.textPrimary),
    titleTextStyle: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: RacheetaColors.textPrimary,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w800),
    displayMedium: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w800),
    displaySmall: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w800),
    headlineMedium: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: RacheetaColors.textPrimary, height: 1.45),
    bodyMedium: TextStyle(color: RacheetaColors.textSecondary, height: 1.45),
    bodySmall: TextStyle(color: RacheetaColors.textSecondary, height: 1.35),
    labelLarge: TextStyle(color: RacheetaColors.textPrimary, fontWeight: FontWeight.w700),
    labelMedium: TextStyle(color: RacheetaColors.textSecondary, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(color: RacheetaColors.textSecondary, fontWeight: FontWeight.w600),
  ),
  iconTheme: const IconThemeData(color: RacheetaColors.primary),
  cardTheme: CardThemeData(
    color: RacheetaColors.card,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: RacheetaColors.border),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: RacheetaColors.card,
    selectedItemColor: RacheetaColors.primary,
    unselectedItemColor: RacheetaColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 12,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: RacheetaColors.primary,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: RacheetaColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      elevation: 0,
      textStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: RacheetaColors.textPrimary,
      minimumSize: const Size.fromHeight(52),
      side: const BorderSide(color: RacheetaColors.border),
      textStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: RacheetaColors.primaryHover,
      textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: RacheetaColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: RacheetaColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: RacheetaColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: RacheetaColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: RacheetaColors.danger),
    ),
    labelStyle: const TextStyle(color: RacheetaColors.textSecondary),
    hintStyle: const TextStyle(color: RacheetaColors.textSecondary),
    prefixIconColor: RacheetaColors.primary,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: RacheetaColors.textPrimary,
    contentTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Cairo',
  scaffoldBackgroundColor: RacheetaColors.darkBackground,
  cardColor: RacheetaColors.darkCard,
  colorScheme: ColorScheme.fromSeed(
    seedColor: RacheetaColors.primary,
    brightness: Brightness.dark,
    primary: RacheetaColors.primary,
    secondary: RacheetaColors.softMint,
    surface: RacheetaColors.darkCard,
    error: RacheetaColors.danger,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: RacheetaColors.darkSurface,
    foregroundColor: RacheetaColors.darkTextPrimary,
    iconTheme: IconThemeData(color: RacheetaColors.darkTextPrimary),
    titleTextStyle: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: RacheetaColors.darkTextPrimary,
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: RacheetaColors.darkTextPrimary, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(color: RacheetaColors.darkTextPrimary, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(color: RacheetaColors.darkTextPrimary, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: RacheetaColors.darkTextPrimary, height: 1.45),
    bodyMedium: TextStyle(color: RacheetaColors.darkTextSecondary, height: 1.45),
    bodySmall: TextStyle(color: RacheetaColors.darkTextSecondary, height: 1.35),
    labelLarge: TextStyle(color: RacheetaColors.darkTextPrimary, fontWeight: FontWeight.w700),
  ),
  iconTheme: const IconThemeData(color: RacheetaColors.primary),
  cardTheme: CardThemeData(
    color: RacheetaColors.darkCard,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: RacheetaColors.darkBorder),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: RacheetaColors.darkSurface,
    selectedItemColor: RacheetaColors.primary,
    unselectedItemColor: RacheetaColors.darkTextSecondary,
    type: BottomNavigationBarType.fixed,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: RacheetaColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      elevation: 0,
      textStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: RacheetaColors.darkCard,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: RacheetaColors.darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: RacheetaColors.darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: RacheetaColors.primary, width: 1.5),
    ),
    labelStyle: const TextStyle(color: RacheetaColors.darkTextSecondary),
    hintStyle: const TextStyle(color: RacheetaColors.darkTextSecondary),
    prefixIconColor: RacheetaColors.primary,
  ),
);
