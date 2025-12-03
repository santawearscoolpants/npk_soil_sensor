import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primaryGreen = Color(0xFF2E7D32);
  const accentBrown = Color(0xFF8D6E63);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryGreen,
    primary: primaryGreen,
    secondary: accentBrown,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: Colors.grey.shade600,
      selectedIconTheme: const IconThemeData(size: 26),
      unselectedIconTheme: const IconThemeData(size: 22),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
  );
}


