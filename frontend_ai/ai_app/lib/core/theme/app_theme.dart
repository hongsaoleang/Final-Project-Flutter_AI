import 'package:flutter/material.dart';

class AppTheme {
  // Eco-friendly, nature-inspired palette
  static const Color primaryColor = Color(0xFF3B5344); // Deep Forest Green
  static const Color primaryLight = Color(0xFF5C7A67); // Sage Green
  static const Color accentMint = Color(0xFFA3B899);   // Pale Mint Accent
  static const Color warmCream = Color(0xFFFAF8F5);   // Warm Off-White / Cream
  static const Color backgroundLight = Color(0xFFF6F4EF);
  static const Color backgroundDark = Color(0xFF131C16);
  static const Color surfaceDark = Color(0xFF19251D);
  static const Color cardDark = Color(0xFF202E25);
  static const Color borderDark = Color(0xFF2D3F33);

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: primaryLight,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF1C2820),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        primary: primaryLight,
        secondary: accentMint,
        surface: cardDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
    );
  }
}
