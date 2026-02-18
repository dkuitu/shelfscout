import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core palette
  static const deepNavy = Color(0xFF0D1B2A);
  static const surfaceCard = Color(0xFF252540);
  static const surfaceLight = Color(0xFF1B2838);

  // Accent colors
  static const goldColor = Color(0xFFFFD600);
  static const conquestGreen = Color(0xFF00E676);
  static const dangerRed = Color(0xFFFF5252);
  static const primaryColor = conquestGreen;
  static const contestedColor = dangerRed;

  // Rarity colors
  static const legendaryGold = Color(0xFFFFD600);
  static const epicPurple = Color(0xFFAA00FF);
  static const rareBlue = Color(0xFF448AFF);
  static const uncommonGreen = Color(0xFF69F0AE);

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.orbitron(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.orbitron(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.orbitron(textStyle: base.displaySmall),
      headlineLarge: GoogleFonts.orbitron(textStyle: base.headlineLarge),
      headlineMedium: GoogleFonts.orbitron(textStyle: base.headlineMedium),
      headlineSmall: GoogleFonts.orbitron(textStyle: base.headlineSmall),
      titleLarge: GoogleFonts.rajdhani(
        textStyle: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      titleMedium: GoogleFonts.rajdhani(
        textStyle: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      titleSmall: GoogleFonts.rajdhani(
        textStyle: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      bodyLarge: GoogleFonts.rajdhani(textStyle: base.bodyLarge),
      bodyMedium: GoogleFonts.rajdhani(textStyle: base.bodyMedium),
      bodySmall: GoogleFonts.rajdhani(textStyle: base.bodySmall),
      labelLarge: GoogleFonts.rajdhani(
        textStyle: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      labelMedium: GoogleFonts.rajdhani(textStyle: base.labelMedium),
      labelSmall: GoogleFonts.rajdhani(textStyle: base.labelSmall),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: deepNavy,
      colorScheme: ColorScheme.dark(
        primary: conquestGreen,
        secondary: goldColor,
        surface: surfaceCard,
        error: dangerRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: deepNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: deepNavy,
        selectedItemColor: conquestGreen,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: conquestGreen,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: conquestGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIconColor: Colors.white38,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        labelStyle: GoogleFonts.rajdhani(color: Colors.white70),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceCard,
        contentTextStyle: GoogleFonts.rajdhani(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: Colors.white12,
    );
  }

  // Gradient helpers
  static LinearGradient get goldGradient => const LinearGradient(
        colors: [Color(0xFFFFD600), Color(0xFFFFA000)],
      );

  static LinearGradient get greenGradient => const LinearGradient(
        colors: [Color(0xFF00E676), Color(0xFF00C853)],
      );

  static LinearGradient get cardGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF252540), Color(0xFF1B2838)],
      );

  static LinearGradient get dangerGradient => const LinearGradient(
        colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
      );
}
