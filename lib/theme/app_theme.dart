import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color.fromARGB(255, 55, 115, 211); // Bright blue
  static const Color secondaryColor = Color(0xFF10B981); // Emerald green
  static const Color accentColor = Color(0xFFF59E0B); // Amber

  // Background & Surface Colors
  static const Color backgroundColor = Color(0xFFF9FAFB); // Off-white
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color darkSurfaceColor = Color(0xFF1F2937); // Dark slate

  // Text Colors
  static const Color primaryTextColor = Color(0xFF111827); // Near black
  static const Color secondaryTextColor = Color(0xFF6B7280); // Medium gray
  static const Color disabledColor = Color(0xFFD1D5DB); // Light gray

  // Graph Colors
  static const List<Color> graphColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Purple
  ];

  // Get the theme data
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: surfaceColor,
        onSecondary: surfaceColor,
        onTertiary: const Color(0xFF1F2937),
        onSurface: primaryTextColor,
        onBackground: primaryTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: surfaceColor,
        elevation: 0,
        toolbarHeight: 72,
        iconTheme: IconThemeData(
          color: surfaceColor,
          size: 28,
        ),
        actionsIconTheme: IconThemeData(
          color: surfaceColor,
          size: 28,
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: surfaceColor,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: surfaceColor,
        elevation: 1,
        indicatorColor: primaryColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: primaryTextColor),
        bodyMedium: TextStyle(color: primaryTextColor),
        bodySmall: TextStyle(color: secondaryTextColor),
        titleLarge: TextStyle(color: primaryTextColor),
        titleMedium: TextStyle(color: primaryTextColor),
        titleSmall: TextStyle(color: primaryTextColor),
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      useMaterial3: true,
      tooltipTheme: const TooltipThemeData(
        showDuration: Duration.zero,
        waitDuration: Duration(milliseconds: 500),
      ),
      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: disabledColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: disabledColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: graphColors[3], width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
} 