import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors (Main Brand Identity)
  static const Color primaryColor = Color(0xFFFF6B57); // Kindness Coral
  static const Color softPrimaryColor =
      Color(0xFFFF9472); // Kindness Coral Light

  // Accent Colors (Highlighting & Emphasis)
  static const Color accentColor = Color(0xFFFFD95A); // Golden Warmth
  static const Color secondaryAccentColor =
      Color(0xFFFFC46C); // Golden Warmth Light

  // Emotional Colors (Feelings & Impact)
  static const Color emotionalColor = Color(0xFFF3B3B3); // Blush Calm
  static const Color supportiveColor = Color(0xFFFFE0DC); // Blush Calm Light

  // Neutral Colors (Structure & Readability)
  static const Color textPrimaryColor = Color(0xFF2D3142); // Dark Text
  static const Color textSecondaryColor = Color(0xFF4F5D75); // Medium Text
  static const Color backgroundColor = Color(0xFFF1E4D4); // Toffee Cream
  static const Color cardColor = Color(0xFFFFF8F0); // Morning Light

  // Functional Colors
  static const Color successColor = Color(0xFFFF9472); // Peach Shine
  static const Color warningColor = Color(0xFFFFD95A); // Golden Warmth
  static const Color errorColor = Color(0xFFFF6B57); // Kindness Coral
  static const Color infoColor = Color(0xFFF3B3B3); // Blush Calm
  static const Color dividerColor = Color(0xFFF1E4D4); // Toffee Cream

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFFFF6B57), // Kindness Coral
    Color(0xFFFF9472), // Kindness Coral Light
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFFD95A), // Golden Warmth
    Color(0xFFFFC46C), // Golden Warmth Light
  ];

  static const List<Color> softGradient = [
    Color(0xFFF3B3B3), // Blush Calm
    Color(0xFFFFE0DC), // Blush Calm Light
  ];

  static const List<Color> neutralGradient = [
    Color(0xFFF1E4D4), // Toffee Cream
    Color(0xFFFFF8F0), // Morning Light
  ];

  static const List<Color> highlightGradient = [
    Color(0xFFFF9472), // Peach Shine
    Color(0xFFFFD95A), // Golden Warmth
  ];

  static const List<Color> glowGradient = [
    Color(0xFFFFF8F0), // Morning Light
    Color(0xFFFFFFFF), // White
  ];

  static const List<Color> emotionalGradient = [
    Color(0xFFF3B3B3), // Blush Calm
    Color(0xFFFFE0DC), // Blush Calm Light
  ];

  static const List<Color> supportiveGradient = [
    Color(0xFFFFE0DC), // Blush Calm Light
    Color(0xFFFFF8F0), // Morning Light
  ];

  // Text styles
  static final TextStyle _baseTextStyle = GoogleFonts.inter(
    color: textPrimaryColor,
    letterSpacing: 0.15,
  );

  static TextStyle get headingLarge => _baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get headingMedium => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get headingSmall => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 12,
        color: textSecondaryColor,
      );

  static TextStyle get buttonText => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryAccentColor,
        tertiary: accentColor,
        error: errorColor,
        background: backgroundColor,
        surface: cardColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: textPrimaryColor,
        onError: Colors.white,
        onBackground: textPrimaryColor,
        onSurface: textPrimaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingMedium.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonText,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryAccentColor,
        tertiary: accentColor,
        error: errorColor,
        background: const Color(0xFF1A1A1A),
        surface: const Color(0xFF2D2D2D),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      cardTheme: CardTheme(
        color: const Color(0xFF2D2D2D),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingMedium.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2D2D2D),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonText,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: headingLarge.copyWith(color: Colors.white),
        displayMedium: headingMedium.copyWith(color: Colors.white),
        displaySmall: headingSmall.copyWith(color: Colors.white),
        bodyLarge: bodyLarge.copyWith(color: Colors.white),
        bodyMedium: bodyMedium.copyWith(color: Colors.white),
        bodySmall: bodySmall.copyWith(color: Colors.grey),
      ),
    );
  }
}
