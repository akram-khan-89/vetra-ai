import 'package:flutter/material.dart';

class StitchColors {
  static const Color primary = Color(0xFF154212); // Deep Forest Green
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2D5A27); // Medium Green
  static const Color onPrimaryContainer = Color(0xFFBCF0AE); // Light/Mint Green
  
  static const Color background = Color(0xFFF9F9F6); // Warm Off-White
  static const Color surface = Color(0xFFF9F9F6);
  static const Color onBackground = Color(0xFF1A1C1B); // Dark Slate/Charcoal
  static const Color onSurface = Color(0xFF1A1C1B);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEEEEEB);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E5);
  static const Color surfaceContainerLow = Color(0xFFF4F4F1);
  
  static const Color error = Color(0xFFBA1A1A); // Crimson
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color outline = Color(0xFF72796E);
  static const Color outlineVariant = Color(0xFFC2C9BB);
  
  static const Color secondary = Color(0xFF006399); // Deep Blue
  static const Color secondaryContainer = Color(0xFF67BAFD);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF001D31);
}

class StitchTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: StitchColors.primary,
        onPrimary: StitchColors.onPrimary,
        primaryContainer: StitchColors.primaryContainer,
        onPrimaryContainer: StitchColors.onPrimaryContainer,
        secondary: StitchColors.secondary,
        onSecondary: StitchColors.onSecondary,
        secondaryContainer: StitchColors.secondaryContainer,
        onSecondaryContainer: StitchColors.onSecondaryContainer,
        error: StitchColors.error,
        onError: StitchColors.onError,
        errorContainer: StitchColors.errorContainer,
        onErrorContainer: StitchColors.onErrorContainer,
        background: StitchColors.background,
        onBackground: StitchColors.onBackground,
        surface: StitchColors.surface,
        onSurface: StitchColors.onSurface,
        outline: StitchColors.outline,
        outlineVariant: StitchColors.outlineVariant,
      ),
      scaffoldBackgroundColor: StitchColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: StitchColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: StitchColors.primary,
        unselectedItemColor: StitchColors.outline,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StitchColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: StitchColors.primary,
          side: const BorderSide(color: StitchColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.outlineVariant, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.outlineVariant, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StitchColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(color: StitchColors.outline, fontSize: 14),
      ),
    );
  }
}
